From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 05/10] sch_generic.c changes.
Date: Sat, 21 Jul 2007 12:54:08 +0530
Message-ID: <OFF2224CCE.8045DF8B-ON6525731F.00287359-6525731F.0028A9BC@in.ibm.com>
References: <OF206CB1B7.31D1C39B-ON6525731F.00254E4C-6525731F.00261F1A@LocalDomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, gaagaan@gmail.com,
	general@lists.openfabrics.org, hadi@cyberus.ca,
	herbert@gondor.apana.org.au, jagana@us.ibm.com, jeff@garzik.org,
	johnpol@2ka.mipt.ru, Patrick McHardy <kaber@trash.net>,
	kumarkr@linux.ibm.com, mcarlson@broadcom.com, mchan@broadcom.com,
	netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com,
	rdreier@cisco.com, rick.jones2@hp.com, Robert.Olsson@data.slu.se,
	sri@us.ibm.com, tgraf@suug.ch, xma@us.ibm.com
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:49462 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753913AbXGUItS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2007 04:49:18 -0400
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.18.232])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l6L9CVG3122384
	for <netdev@vger.kernel.org>; Sat, 21 Jul 2007 19:12:31 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6L8miQM059904
	for <netdev@vger.kernel.org>; Sat, 21 Jul 2007 18:48:44 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6L8nDP6004339
	for <netdev@vger.kernel.org>; Sat, 21 Jul 2007 18:49:16 +1000
In-Reply-To: <OF206CB1B7.31D1C39B-ON6525731F.00254E4C-6525731F.00261F1A@LocalDomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krishna Kumar2/India/IBM wrote on 07/21/2007 12:26:23 PM:

> Hi Patrick,
>
> Patrick McHardy <kaber@trash.net> wrote on 07/20/2007 11:46:36 PM:
>
> > The check for tx_queue_len is wrong though,
> > its only a default which can be overriden and some qdiscs don't
> > care for it at all.

> I think it should not matter whether qdiscs use this or not, or even if
it
> is modified (unless it is made zero in which case this breaks). The
> intention behind this check is to make sure that not more than
tx_queue_len
> skbs are in all queues put together (q->qdisc + dev->skb_blist),
otherwise
> the blist can become too large and breaks the idea of tx_queue_len. Is
that
> a good justification ?

Also, if tx_queue_len is set to zero, I think my code will not execute and
the existing code will break at rc = q->enqueue() (for sched's checking
queue
limits).

