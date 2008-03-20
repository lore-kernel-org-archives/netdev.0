From: Glen Gray <glen.gray@lincor.com>
Subject: r8169 driver fails to see IGMPv2 SAP announcements
Date: Thu, 20 Mar 2008 10:44:54 +0000
Message-ID: <DE885BD6-C428-48D5-90F4-32C9227F256F@lincor.com>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset="US-ASCII"; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.station1.mxsweep.com ([212.147.136.149]:2005 "EHLO
	scmp07.mxsweep.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751853AbYCTKq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 06:46:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This has been a continuing problem with the kernel Realtek drivers  
since 2.6.19 and as of testing on Fedora 8 with their 2.6.24.3, things  
are no different.

Is there any suggestions as to why this isn't working ?

The SAP announcements are made via IGMPv2, however the eth0 device  
comes up as IGMPv3 and so doesn't pick up the announcements. I've used  
the proc interface force_igmp_version to set all devices to v2, but it  
doesn't seem to make any difference.

The Realtek driver does correctly see the SAP announcements (/proc/net/ 
igmp shows it as a V2) but has proven to be unstable after long up  
times or many multicast subscriptions (e.g. changing from one  
multicast IPTV channel to another every 30 seconds shows serious data  
loss after an hour or so).

To get around this I'm using the Realtek driver with a stability patch  
kindly provided by Francois Romieu which removed the worst of the  
stability issues. But we still need to reboot these units on a nightly  
basis in order to keep the issues with the driver stack locking up to  
a minimum. I'd much rather use the standard kernel if I could get it  
to work correctly with SAP.

Suggestions and feedback most welcome,
--
Glen Gray <glen.gray@lincor.com>         Digital Depot, Thomas Street
Senior Software Engineer                            Dublin 8, Ireland
Lincor Solutions Ltd.                          Ph: +353 (0) 1 4893682

