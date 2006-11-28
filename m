From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: Broken commit: [NETFILTER]: ipt_REJECT: remove largely duplicate route_reverse function
Date: Tue, 28 Nov 2006 21:48:40 +0100
Message-ID: <m3wt5fb8lz.fsf@defiant.localdomain>
References: <m3fyc3e84s.fsf@defiant.localdomain> <456C94D2.9000602@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@lists.netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:50623 "EHLO khc.piap.pl")
	by vger.kernel.org with ESMTP id S1754665AbWK1UtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Nov 2006 15:49:13 -0500
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <456C94D2.9000602@trash.net> (Patrick McHardy's message of "Tue, 28 Nov 2006 20:58:10 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

>> The following commit breaks ipt_REJECT on my machine. Tested with latest
>> 2.6.19rc*, found with git-bisect. i386, gcc-4.1.1, the usual stuff.
>> All details available on request, of course.
>> 
>> commit 9d02002d2dc2c7423e5891b97727fde4d667adf1
>
> How sure are you about this? I can see nothing wrong with that
> commit and can't reproduce the slab corruption. Please post
> the rule that triggers this.

99% sure. Past this commit I get corruptions after 5 minutes at most
(that's ADSL with USB Thomson/Alcatel Speedtouch -> PPP over ATM,
with a GRE tunnel over that PPP).
I'm now running 901eaf6c8f997f18ebc8fcbb85411c79161ab3b2 (i.e. the
last commit before the one in question) for 4 hours and nothing like
that.

Not sure about the exact rule, but the most probable candidates are:
-A INPUT -p tcp --tcp-flags SYN,RST,ACK SYN -j REJECT --reject-with tcp-reset
-A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable

Other "REJECT" rules haven't fired yet.

Could be some obscure problem with GRE/Speedtouch/PPP over ATM,
triggered by this patch, though.

Perhaps I can do some experiments - just say a word.
--
Krzysztof Halasa
