From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: [PATCH][BRIDGE-NF] Fix wrong use of skb->protocol
Date: Fri, 31 Dec 2004 11:51:00 +0100
Message-ID: <1104490260.3373.15.camel@localhost.localdomain>
References: <1104432914.15601.19.camel@localhost.localdomain>
	 <20041230222415.GB19587@xi.wantstofly.org>
	 <1104448248.15601.55.camel@localhost.localdomain>
	 <20041231083352.GA25031@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        snort2004@mail.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041231083352.GA25031@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Op vr, 31-12-2004 te 09:33 +0100, schreef Lennert Buytenhek:

> Just one more thing: AFAIK it is possible to inject a raw IPv4 packet
> with an invalid IPv4 header.  So maybe the better 'fix' would be to have
> different hooks for PF_INET and PF_INET6, and distinguish v4/v6 packets
> that way instead of peeking into the header.  (The hook you're talking
> about is a PF_INET* and not a PF_BRIDGE hook, right?)

That was my original plan, but it seems such a waste.
Wouldn't injecting such an invalid IPv4 header also screw up iptables?
Is there any reason why someone should be allowed to do this?
I checked ip_tables.c::ipt_do_table() before using the IP version, and
it looks at the IP header too without any precautions AFAICT.

> Then again, that would add yet another function onto the already rather
> deep call chains that we have in there.

The netfilter scheme itself implies call chains.

> Too bad I don't see any cleaner way of integrating the whole bridging
> thing into the stack.  I wonder if any of the *BSDs found a cleaner way
> of doing this.

How about adding something like NF_STOP, which acts like NF_STOLEN but
still executes okfn in nf_hook_slow()?

cheers,
Bart
