From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next 06/13] net: original ingress device index in
 PKTINFO
Date: Thu, 5 May 2016 23:00:36 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1605052248480.2328@ja.home.ssi.bg>
References: <1462419210-10463-1-git-send-email-dsa@cumulusnetworks.com> <1462419210-10463-7-git-send-email-dsa@cumulusnetworks.com> <alpine.LFD.2.11.1605051040320.2118@ja.home.ssi.bg> <572B6012.60806@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:58162 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756210AbcEEUAn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2016 16:00:43 -0400
In-Reply-To: <572B6012.60806@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 5 May 2016, David Ahern wrote:

> On 5/5/16 2:41 AM, Julian Anastasov wrote:

> > > +	IPCB(skb)->iif = skb->skb_iif;
> >
> > 	For loopback traffic (including looped back multicast)
> > this is now a zero :( Can inet_iif be moved to ip_rcv_finish
> > instead? Still, we spend cycles in fast path in case nobody
> > listens for such info.
> 
> Why is that? skb_iif is set to skb->dev->index in __netif_receive_skb_core and
> ip_rcv is called it. Is there another path to it?

	You are right, it is 0 only for the output path.

Regards
