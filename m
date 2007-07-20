From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 03/10] dev.c changes.
Date: Fri, 20 Jul 2007 15:57:37 +0530
Message-ID: <OFC586F180.42DDCDC5-ON6525731E.0038D792-6525731E.00397615@in.ibm.com>
References: <46A088AE.1090702@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, gaagaan@gmail.com,
	general@lists.openfabrics.org, hadi@cyberus.ca,
	herbert@gondor.apana.org.au, jagana@us.ibm.com, jeff@garzik.org,
	johnpol@2ka.mipt.ru, kumarkr@linux.ibm.com, mcarlson@broadcom.com,
	mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, rdreier@cisco.com,
	rick.jones2@hp.com, Robert.Olsson@data.slu.se, sri@us.ibm.com,
	tgraf@suug.ch, xma@us.ibm.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:56914 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753889AbXGTLPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 07:15:07 -0400
Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l6KBbX1E162794
	for <netdev@vger.kernel.org>; Fri, 20 Jul 2007 21:37:34 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6KBHpdp027154
	for <netdev@vger.kernel.org>; Fri, 20 Jul 2007 21:17:52 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6KBDlqK022341
	for <netdev@vger.kernel.org>; Fri, 20 Jul 2007 21:13:52 +1000
In-Reply-To: <46A088AE.1090702@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Patrick,

Thanks for your comments.

Patrick McHardy <kaber@trash.net> wrote on 07/20/2007 03:34:30 PM:

> The queue length can be changed through multiple interfaces, if that
> really is important you need to catch these cases too.

I have a TODO comment in net-sysfs.c which is to catch this case.

> > +      } else {
> > +         dev->skb_blist = kmalloc(sizeof *dev->skb_blist,
> > +                   GFP_KERNEL);
>
>
> Why not simply put the head in struct net_device? It seems to me that
> this could also be used for gso_skb.

Without going into GSO, it is wasting some 32 bytes on i386 since most
drivers
don't export this API.

> Queue purging should be done in dev_deactivate.

I originally had it in dev_deactivate, but when I did a ifdown eth0, ifup
eth0,
the system panic'd. The first solution I thought was to initialize the
skb_blist
in dev_change_flags() rather than in register_netdev(), but then felt that
a
series of ifup/ifdown will unnecessarily check stuff/malloc/free/initialize
stuff,
and so thought of putting it in unregister_netdev (where it is balanced
with
register_netdev).

Is there any reason to move this ?

Thanks,

- KK

