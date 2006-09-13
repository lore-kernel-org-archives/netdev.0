From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 0/5] pcnet32: NAPI implementation (one more try)
Date: Wed, 13 Sep 2006 10:15:23 -0700
Message-ID: <20060913171523.GA12714@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:17062 "EHLO
	e34.co.us.ibm.com") by vger.kernel.org with ESMTP id S1750796AbWIMROg
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 13:14:36 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8DHEZ4O015329
	for <netdev@vger.kernel.org>; Wed, 13 Sep 2006 13:14:35 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8DHEZx0253768
	for <netdev@vger.kernel.org>; Wed, 13 Sep 2006 11:14:35 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8DHEYjQ029781
	for <netdev@vger.kernel.org>; Wed, 13 Sep 2006 11:14:35 -0600
To: tsbogend@alpha.franken.de, jgarzik@pobox.com,
	netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches to the pcnet32 driver implement NAPI and respond to some
other suggestions found during NAPI development and testing.

The first patch deletes a couple of unnecessary save/restore operations.
The second patch replaces some magic numbers with hopefully more clear
defines.
The third patch moves the receive and creates a transmit routine.
The fourth patch breaks the receive routine into two pieces to make the
code easier to read and simpler.
The fifth and final patch implements the NAPI changes.

The comments from Francois Romieu regarding using spin_lock instead of
spin_lock_irqsave were investigated, but since interrupts have to be
disabled to prevent the interrupt handler from deadlocking, and since I
would probably forget sometime, it is safer to leave the locking as it
is.  The requested mmiowb calls were added.

Please appply to 2.6.19.

[PATCH 1/5] pcnet32:  remove unnecessary save/restore register accesses.
[PATCH 2/5] pcnet32:  magic number cleanup
[PATCH 3/5] pcnet32:  move/create receive and transmit routines
[PATCH 4/5] pcnet32:  break receive routine into two pieces.
[PATCH 5/5] pcnet32:  NAPI implementation
-- 
Don Fry
brazilnut@us.ibm.com
