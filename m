From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Information about napi_struct and net_device
Date: Sat, 27 Oct 2012 19:03:41 +0200
Message-ID: <1351357421.30380.328.camel@edumazet-glaptop>
References: <CALZVap=ybdWdK22LHsfSRu+TVCJnvL95KeChtCdX8DE-C=1gAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Javier Domingo <javierdo1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:58303 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751765Ab2J0RDp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Oct 2012 13:03:45 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so1205931eaa.19
        for <netdev@vger.kernel.org>; Sat, 27 Oct 2012 10:03:44 -0700 (PDT)
In-Reply-To: <CALZVap=ybdWdK22LHsfSRu+TVCJnvL95KeChtCdX8DE-C=1gAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-10-27 at 18:18 +0200, Javier Domingo wrote:
> Hello,
> 
> I am updating a kernel patch from 2.6.23-rc7 to v3.6, using git
> facilities, and I have found that there have been lots of changes in
> networking. Now the drivers are all by vendor, and more important,
> net_device is not used always, as napi_struct took its place.
> 

Yes, some directories were created and files moved around.

Not really a big deal (no real code change)


> I have asked in #kernel but no one answered me, so I subscribed here.
> Is there any place I can read about how is it now designed the use of
> napi_struct and net_device? I have found a presentation[1] about how
> networking was changing etc, and I wondered if there is anything more
> precise about how it is actually implemented.
> 
> I understand a little why napi_struct, but don't really know much
> about the change,
> 
> Hope someone can help me,

Seems quite straightforward, we probably should add some docs in 
Documentation/networking/netdevices.txt

You could take a look at a small driver like
drivers/net/ethernet/realtek/8139cp.c

and grep for "napi" in it


# grep -n napi drivers/net/ethernet/realtek/8139cp.c
327:	struct napi_struct	napi;
436:	napi_gro_receive(&cp->napi, skb);
468:static int cp_rx_poll(struct napi_struct *napi, int budget)
470:	struct cp_private *cp = container_of(napi, struct cp_private, napi);
566:		napi_gro_flush(napi, false);
568:		__napi_complete(napi);
605:		if (napi_schedule_prep(&cp->napi)) {
607:			__napi_schedule(&cp->napi);
1132:	napi_enable(&cp->napi);
1149:	napi_disable(&cp->napi);
1160:	napi_disable(&cp->napi);
1933:	netif_napi_add(dev, &cp->napi, cp_rx_poll, 16);
