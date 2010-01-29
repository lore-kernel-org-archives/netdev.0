From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: [PATCH 0/3][v2] tcp: fix ICMP-RTO war
Date: Fri, 29 Jan 2010 23:15:51 +0100
Message-ID: <4B635E17.406@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7BIT
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:54450 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752554Ab0A2WPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 17:15:52 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KX100C4V4IFDL00@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Fri, 29 Jan 2010 23:15:51 +0100 (CET)
Received: from [137.226.143.131] (nexus.tvk.RWTH-Aachen.DE [137.226.143.131])
	by relay.rwth-aachen.de (8.13.8+Sun/8.13.8/1) with ESMTP id o0TMFptK019717	for
 <netdev@vger.kernel.org>; Fri, 29 Jan 2010 23:15:51 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patches fix the current RTO calculation routine, when
srtt and rttvar are zero, yielding an RTO of zero 
Under some circumstances, TCPs srtt and rttvar are zero,
yielding a calculated RTO of zero.
This is particularly unfortunate for ICMP based RTO recalculation
as introduced in f1ecd5d9e736660 (Revert Backoff [v3]: Revert RTO
on ICMP destination unreachable), as it results in RTO retransmission
flooding.

Thanks to Ilpo Jarvinen for providing debug patches and to
Denys Fedoryshchenko for reporting and testing.

Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
