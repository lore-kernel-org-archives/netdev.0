From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 0/3] pcnet32: reorg, NAPI, and cleanup
Date: Mon, 11 Sep 2006 10:45:09 -0700
Message-ID: <20060911174509.GA3938@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:15523 "EHLO e6.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751134AbWIKRoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2006 13:44:38 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8BHiesb024467
	for <netdev@vger.kernel.org>; Mon, 11 Sep 2006 13:44:40 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8BHia4Q285714
	for <netdev@vger.kernel.org>; Mon, 11 Sep 2006 13:44:37 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8BHialB019224
	for <netdev@vger.kernel.org>; Mon, 11 Sep 2006 13:44:36 -0400
To: tsbogend@alpha.franken.de, jgarzik@pobox.com,
	netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches to the pcnet32 driver implement NAPI and respond to some
other suggestions found during NAPI development and testing.

The NAPI code change was broken into two pieces, one is
code-reorganization, and the second is the NAPI implementation.  Tested
with and without NAPI ia32 and ppc64 with '970A, '971, '972, and '976.

The comments from Francois Romieu regarding using spin_lock instead of
spin_lock_irqsave were investigated, but since interrupts have to be
disabled to prevent the interrupt handler from deadlocking, and since I
would probably forget sometime, it is safer to leave the locking as it
is.  The requested mmiowb calls were added.

Please appply to 2.6.19.

1/3 Code reorganization to facilitate NAPI.
2/3 NAPI implementation.
3/3 Magic number cleanup.
-- 
Don Fry
brazilnut@us.ibm.com
