From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Increase snd/rcv buffers in pppoe
Date: Mon, 23 Feb 2004 20:12:01 +0000 (UTC)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040225211526.74478066.ak@suse.de>
References: <20040223105359.GA91938@colin2.muc.de>
	<20040223.200101.39143636.yoshfuji@linux-ipv6.org>
	<20040223111659.GB10681@colin2.muc.de>
	<20040223.203843.04073965.yoshfuji@linux-ipv6.org>
	<20040223102613.33838132.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, ak@muc.de, netdev@oss.sgi.com,
        mostrows@styx.uwaterloo.ca
Return-path: <netdev-bounce@oss.sgi.com>
Date: Wed, 25 Feb 2004 21:15:26 +0100
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040223102613.33838132.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 23 Feb 2004 10:26:13 -0800
"David S. Miller" <davem@redhat.com> wrote:

> 
> The proposal I make intends to avoid this endless tweaking.

[...] Sounds good to me.
 
> Two more observations while grepping for SK_{R,W}MEM_MAX.
> 
> 1) IPV4 icmp sents sk_sndbuf of it's sockets to "2 * SK_WMEM_MAX", that's not
>    what it really wants.  What it really wants is enough space to hold
>    ~2 full sized IPV4 packets, roughly 2 * 64K + struct sk_buff overhead
>    and thus that is what it should be using there.

Just sk_buff overhead for what MTU? 576? (would be a bit extreme)
And in theory it could be one byte packets too.

> 2) IPV6 icmp does the same as ipv4, except this value is even more wrong there
>    especially considering jumbograms.  With current code, sending a jumbogram
>    ipv6 icmp packet would simply fail, and I wonder if anyone has even tried
>    this.

Isn't even ICMPv6 limited to the minimum guaranteed MTU (1000 something) like ICMPv4 is to
576 bytes?

-Andi
