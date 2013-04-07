From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: PROBLEM: IPv6 TCP-Connections resetting
Date: Sun, 07 Apr 2013 16:37:04 +0200
Message-ID: <2517820.omWyusa00U@cpaasch-mac>
References: <20130405174828.310a02c3@trediske.ws.office.manitu.net> <1460015.zN3jPXiAbD@cpaasch-mac> <1365270879.3887.4.camel@edumazet-glaptop>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Tetja Rediske <tetja@tetja.de>, djduanjiong@gmail.com,
	netdev@vger.kernel.org, steffen.klassert@secunet.com,
	Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:48830 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933825Ab3DGOhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 10:37:23 -0400
In-Reply-To: <1365270879.3887.4.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 06 April 2013 10:54:39 Eric Dumazet wrote:
> OK, it seems bug was added in commit
> ec18d9a2691d69cd14b48f9b919fddcef28b7f5c
> (ipv6: Add redirect support to all protocol icmp error handlers.)
> 
> Not sure why Tetja Rediske  bisected to
> 093d04d42fa094f6740bb188f0ad0c215ff61e2c

I made a setup to trigger the ICMPv6 Redirect.
Yes, the bug was added by ec18d9a26 (ipv6: Add redirect support to all 
protocol icmp error handlers.), but prior to 093d04d4 (ipv6: Change skb->data 
before using icmpv6_notify() to propagate redirect) the stack did not enter 
tcp_v6_err upon a redirect message.

This, because inside icmpv6_notify, skb->data did not point to the inner IP 
header. So, when icmpv6_notify looks up the protocol-handler, it will not 
match on tcp_v6_err.

> Could you send a patch with this single line change (no cleanup), and
> a more detailed changelog, once the bug origin is clearly identified ?

Yes, will resend.


Cheers,
Christoph

-- 
IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://multipath-tcp.org
UCLouvain
--
