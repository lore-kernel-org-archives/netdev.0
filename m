From: Michal Soltys <soltys@ziu.info>
Subject: question: tg3 driver/nics and inconsistent RX ring count
Date: Tue, 26 Jul 2016 21:52:50 +0200
Message-ID: <01ffefd8-8191-b423-0ccf-feb2d769d8d2@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([84.10.39.251]:36355 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757532AbcGZTxB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2016 15:53:01 -0400
Received: from [10.0.0.2] (89-65-85-89.dynamic.chello.pl [89.65.85.89])
	(Authenticated sender: nozo)
	by drutsystem.com (Postfix) with ESMTPA id C15F49371F
	for <netdev@vger.kernel.org>; Tue, 26 Jul 2016 21:52:50 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a few of BCM5720 and BCM5719 kinds sitting in Dell R320 and R520
servers - and all of them have certain peculiarity: they claim to have
up to 4 TX and RX rings (and this can be set/verified just fine through
ethtool -l/-L, with driver defaulting to 4 rings), indirection table
(ethtool -x) looks fine as well:

RX flow hash indirection table for eth1b with 3 RX ring(s):
    0:      0     1     2     3     0     1     2     3
    8:      0     1     2     3     0     1     2     3
......

But this "3 RX ring(s)" is actually a real limit if I try to adjust
anything, for example all those commands would fail:

ethtool -X eth1b equal 4
ethtool -X eth1b weight 1 1 1 1

But would work fine for 3 and less rings. This was quickly tested with
different kernel/ethtool combinations, from old 3.16 to 4.6.y with same
exact results. Nothing fancier (-N/-U) is supported either.

Any hints/comments about the cause of this and/or possible workarounds ?
