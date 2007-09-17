From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 2/10 REV5] [core] Add skb_blist & support for batching
Date: Mon, 17 Sep 2007 09:21:45 +0530
Message-ID: <OFB45E9AD1.813A34E4-ON65257359.00150C57-65257359.001537DE@in.ibm.com>
References: <20070914124637.GC18517@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, gaagaan@gmail.com,
	general@lists.openfabrics.org, hadi@cyberus.ca,
	herbert@gondor.apana.org.au, jagana@us.ibm.com, jeff@garzik.org,
	kaber@trash.net, kumarkr@linux.ibm.com, mcarlson@broadcom.com,
	mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, randy.dunlap@oracle.com,
	rdreier@cisco.com, rick.jones2@hp.com, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, sri@us.ibm.com, tgraf@suug.ch,
	xma@us.ibm.com
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from E23SMTP06.au.ibm.com ([202.81.18.175]:41898 "EHLO
	e23smtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbXIQDuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 23:50:44 -0400
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8H3oUcT005424
	for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 13:50:30 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8H3oUcG4456564
	for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 13:50:30 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8H3oSn2029274
	for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 13:50:30 +1000
In-Reply-To: <20070914124637.GC18517@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Evgeniy,

Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote on 09/14/2007 06:16:38 PM:

> > +   if (dev->features & NETIF_F_BATCH_SKBS) {
> > +      /* Driver supports batching skb */
> > +      dev->skb_blist = kmalloc(sizeof *dev->skb_blist, GFP_KERNEL);
> > +      if (dev->skb_blist)
> > +         skb_queue_head_init(dev->skb_blist);
> > +   }
> > +
>
> A nitpick is that you should use sizeof(struct ...) and I think it
> requires flag clearing in cae of failed initialization?

I thought it is better to use *var name in case the name of the structure
changes. Also, the flag is not cleared since I could try to enable batching
later, and it could succeed at that time. When skb_blist is allocated, then
batching is enabled otherwise it is disabled (while features flag just
indicates that driver supports batching).

Thanks,

- KK

