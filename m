From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 00/12 -Rev2] Implement batching skb API
Date: Sun, 22 Jul 2007 14:34:57 +0530
Message-ID: <20070722090457.7787.4601.sendpatchset@K50wks273871wss.in.ibm.com>
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, kumarkr@linux.ibm.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	mcarlson@broadcom.com, xma@us.ibm.com, rick.jones2@hp.com,
	hadi@cyberus.ca, jeff@garzik.org, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, netdev@vger.kernel.org,
	jagana@us.ibm.com, kaber@trash.net,
	Krishna Kumar <krkumar2@in.ibm.com>, sri@us.ibm.com
To: davem@davemloft.net, rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp05.au.ibm.com ([202.81.18.154]:34056 "EHLO
	ausmtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756154AbXGVJEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2007 05:04:32 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp05.au.ibm.com (8.13.8/8.13.8) with ESMTP id l6M95dH62666688
	for <netdev@vger.kernel.org>; Sun, 22 Jul 2007 19:05:39 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6M980EJ196700
	for <netdev@vger.kernel.org>; Sun, 22 Jul 2007 19:08:00 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6M94PvO008621
	for <netdev@vger.kernel.org>; Sun, 22 Jul 2007 19:04:27 +1000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This set of patches implements the batching API, and makes the following
changes resulting from the review of the first set:

Changes :
---------
1.  Changed skb_blist from pointer to static as it saves only 12 bytes
    (i386), but bloats the code.
2.  Removed requirement for driver to set "features & NETIF_F_BATCH_SKBS"
    in register_netdev to enable batching as it is redundant. Changed this
    flag to NETIF_F_BATCH_ON and it is set by register_netdev, and other
    user changable calls can modify this bit to enable/disable batching.
3.  Added ethtool support to enable/disable batching (not tested).
4.  Added rtnetlink support to enable/disable batching (not tested).
5.  Removed MIN_QUEUE_LEN_BATCH for batching as high performance drivers
    should not have a small queue anyway (adding bloat).
6.  skbs are purged from dev_deactivate instead of from unregister_netdev
    to drop all references to the device.
7.  Removed changelog in source code in sch_generic.c, and unrelated renames
    from sch_generic.c (lockless, comments).
8.  Removed xmit_slots entirely, as it was adding bloat (code and header)
    and not adding value (it is calculated and set twice in internal send
    routine and handle work completion, and referenced once in batch xmit;
    and can instead be calculated once in xmit).

Issues :
--------
1. Remove /sysfs support completely ?
2. Whether rtnetlink support is required as GSO has only ethtool ?

Patches are described as:
	Mail 0/12  : This mail.
	Mail 1/12  : HOWTO documentation.
	Mail 2/12  : Changes to netdevice.h
	Mail 3/12  : dev.c changes.
	Mail 4/12  : Ethtool changes.
	Mail 5/12  : sysfs changes.
	Mail 6/12  : rtnetlink changes.
	Mail 7/12  : Change in qdisc_run & qdisc_restart API, modify callers
		     to use this API.
	Mail 8/12  : IPoIB include file changes.
	Mail 9/12  : IPoIB verbs changes
	Mail 10/12 : IPoIB multicast, CM changes
	Mail 11/12 : IPoIB xmit API addition
	Mail 12/12 : IPoIB xmit internals changes (ipoib_ib.c)

I have started a 10 run test for various buffer sizes and processes, and
will post the results on Monday.

Please review and provide feedback/ideas; and consider for inclusion.

Thanks,

- KK
