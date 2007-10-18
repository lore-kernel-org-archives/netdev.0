From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 0/6] bonding workqueue and lock rework
Date: Wed, 17 Oct 2007 17:37:44 -0700
Message-ID: <1192667871139-git-send-email-fubar@us.ibm.com>
Cc: andy@greyhouse.net
To: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:38716 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761771AbXJRAh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 20:37:59 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9I0btFJ024930
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 20:37:55 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9I0btR3414222
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 18:37:55 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9I0btSU021251
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 18:37:55 -0600
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	Following are patches to update the locking used in the bonding
driver.  This involves two basic changes: conversion from timers to
workqueues for the various periodic monitor functions, and conversion of
locking.  These patches should resolve the majority of locking and
might sleep related warnings that occur during certain operations.

	The workqueue conversion is fairly straightforward, and
substitutes workqueue driven events for the existing timer driven events.

	The locking changes are of two types: first, changes to resolve
deadlocks created by the conversion to workqueues, and second, changes to
make the locking more correct, which generally involves holding RTNL and
no other locks during specific operations.  Some of the RTNL-related
changes are fairly extensive, and involve either conditional locking or
releasing and reacquiring locks in order to obey lock ordering
constraints.

	These changes were developed and extensively tested by Andy
Gospodarek <andy@greyhouse.net> and myself over the last few months.

	Patches are relative to linux-2.6.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
