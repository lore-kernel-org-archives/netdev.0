From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] gre: conform to RFC6040 ECN progogation
Date: Tue, 25 Sep 2012 00:25:36 +0200
Message-ID: <1348525536.26828.1885.camel@edumazet-glaptop>
References: <20120924184304.727711327@vyatta.com>
	 <20120924185050.162920909@vyatta.com>
	 <20120924205822.GI26494@x200.localdomain>
	 <20120924141133.3c97e9de@nehalam.linuxnetplumber.net>
	 <20120924212226.GJ26494@x200.localdomain>
	 <20120924144457.0c76bce2@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Chris Wright <chrisw@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:47608 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750778Ab2IXWZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 18:25:41 -0400
Received: by weyt9 with SMTP id t9so519872wey.19
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2012 15:25:40 -0700 (PDT)
In-Reply-To: <20120924144457.0c76bce2@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-24 at 14:44 -0700, Stephen Hemminger wrote:
> Linux GRE was likely written before this RFC and therefore does not
> conform to one of the rules in Section 4.2.  Default Tunnel Egress Behaviour.
> 
> The new code addresses:
>  o If the inner ECN field is Not-ECT, the decapsulator MUST NOT
>       propagate any other ECN codepoint onwards.  This is because the
>       inner Not-ECT marking is set by transports that rely on dropped
>       packets as an indication of congestion and would not understand or
>       respond to any other ECN codepoint [RFC4774].  Specifically:
> 
>       *  If the inner ECN field is Not-ECT and the outer ECN field is
>          CE, the decapsulator MUST drop the packet.
> 
>       *  If the inner ECN field is Not-ECT and the outer ECN field is
>          Not-ECT, ECT(0), or ECT(1), the decapsulator MUST forward the
>          outgoing packet with the ECN field cleared to Not-ECT.
> 
> This was caught by Chris Wright while reviewing VXLAN.
> This code has not been tested with real ECN through tunnel.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

It seems dangerous to me without any logging ?

One could argue that the outer ECN field should not be CE if the inner
was Not-ECT

It means :
1) the encapsulator set ECT(0), or ECT(1) and a congestioned hop set CE
2) the encapsulator set CE

1) or 2) while inner was not-ECT (!!!)

If a router does such a thing, we should log a message to help
diagnostics.

By the way other tunnels probably have the same issues.
