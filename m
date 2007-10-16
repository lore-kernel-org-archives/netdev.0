From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Multicast problem
Date: Tue, 16 Oct 2007 10:04:39 -0700
Message-ID: <OFB45E9AE1.F95FB289-ON88257376.005D25C3-88257376.005DB70D@us.ibm.com>
References: <1192553387.30006.29.camel@gentoo-jocke.transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Netdev <netdev@vger.kernel.org>
To: joakim.tjernlund@transmode.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:35154 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751631AbXJPREo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 13:04:44 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9GH4hkS028995
	for <netdev@vger.kernel.org>; Tue, 16 Oct 2007 13:04:43 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9GH4ffh322964
	for <netdev@vger.kernel.org>; Tue, 16 Oct 2007 11:04:42 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9GH4f5k026680
	for <netdev@vger.kernel.org>; Tue, 16 Oct 2007 11:04:41 -0600
In-Reply-To: <1192553387.30006.29.camel@gentoo-jocke.transmode.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If you have icmp_echo_ignore_broadcasts set to 1, it won't respond to
multicasts. That should be all you need to do for 224.0.0.1.

Some smart switches rely on IGMP snooping to determine group membership,
and some of those don't understand IGMPv3, so if you have no v1 or v2 
queriers
on the network, you can force the IGMP version to be 2 instead of the 
default 3
by using a sysctl. But that's not the issue for 224.0.0.1, since the 
all-hosts group
is not reported via IGMP.

You might check the contents of /proc/net/igmp and /proc/net/dev_mcast to 
make
sure they have entries for the group. If so, I'd guess it might be a 
driver or device issue.

                                                        +-DLS

