From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 0/10 REV5] Implement skb batching and support in IPoIB/E1000
Date: Mon, 17 Sep 2007 09:38:36 +0530
Message-ID: <OF4096F552.5B89C6BA-ON65257359.0016534B-65257359.0016C2D0@in.ibm.com>
References: <20070916.161748.48388692.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: gaagaan@gmail.com, general@lists.openfabrics.org, hadi@cyberus.ca,
	herbert@gondor.apana.org.au, jagana@us.ibm.com, jeff@garzik.org,
	johnpol@2ka.mipt.ru, kaber@trash.net, kumarkr@linux.ibm.com,
	mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, randy.dunlap@oracle.com,
	rdreier@cisco.com, rick.jones2@hp.com, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, sri@us.ibm.com, tgraf@suug.ch,
	xma@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from E23SMTP03.au.ibm.com ([202.81.18.172]:38403 "EHLO
	e23smtp03.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790AbXIQEH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 00:07:27 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8H47C5s023564
	for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 14:07:12 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8H4AjBT029984
	for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 14:10:45 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8H56qwh018794
	for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 15:06:54 +1000
In-Reply-To: <20070916.161748.48388692.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

David Miller <davem@davemloft.net> wrote on 09/17/2007 04:47:48 AM:

> The only major complaint I have about this patch series is that
> the IPoIB part should just be one big changeset.  Otherwise the
> tree is not bisectable, for example the initial ipoib header file
> change breaks the build.

Right, I will change it accordingly.

> On a lower priority, I question the indirection of skb_blist by making
> it a pointer.  For what?  Saving 12 bytes on 64-bit?  That kmalloc()'d
> thing is a nearly guarenteed cache and/or TLB miss.  Just inline the
> thing, we generally don't do crap like this anywhere else.

The intention was to avoid having two flags (one that driver supports
batching and second to indicate that batching is on/off). So I could test
skb_blist as an indication of whether batching is on/off. But your point
on cache miss is absolutely correct, and I will change this part to be
inline.

thanks,

- KK

