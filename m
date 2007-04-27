From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: r8169 ethernet bonding problems
Date: Fri, 27 Apr 2007 14:30:49 -0700
Message-ID: <12883.1177709449@death>
References: <9e246b4d0704180552q16b05017wd0d7041c3ce04f46@mail.gmail.com> <20070418181333.GA2261@electric-eye.fr.zoreil.com> <9e246b4d0704271353g105ecd62j4f35a6e9027ad590@mail.gmail.com>
Cc: "Francois Romieu" <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: "Tim Durack" <tdurack@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:41669 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597AbXD0Vaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 17:30:52 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l3RLUqV4000429
	for <netdev@vger.kernel.org>; Fri, 27 Apr 2007 17:30:52 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l3RLUplr172460
	for <netdev@vger.kernel.org>; Fri, 27 Apr 2007 15:30:51 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l3RLUpYI005092
	for <netdev@vger.kernel.org>; Fri, 27 Apr 2007 15:30:51 -0600
In-reply-to: <9e246b4d0704271353g105ecd62j4f35a6e9027ad590@mail.gmail.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tim Durack <tdurack@gmail.com> wrote:

[...]
>Bond comes up, cannot ping unless I manually force promisc on both member links:
>
>ip link set dev eth1 promisc on
>ip link set dev eth2 promisc off

	From looking at the source code for r8169, but it appears that
the r8169 driver only reads the device MAC address at probe time, and
doesn't propogate changes to the MAC out to the device.  That might
explain the "promisc" problem if the device also does MAC filtering.  Am
I missing something in the driver?

	I don't actually have one of these to test with, I'm just
looking at the source and observing that dev_addr is only ever
referenced in the probe function, and that's only to read in the MAC
from the device.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
