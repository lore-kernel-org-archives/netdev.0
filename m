From: "Alex Lyakas" <alex@zadarastorage.com>
Subject: bond failover doesn't happen when active slave link is up, but there is no connectivity
Date: Mon, 3 Mar 2014 18:49:04 +0200
Message-ID: <62EB227014B44F00A9ACC9C781887FC8@alyakaslap>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:37935 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753581AbaCCQtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 11:49:08 -0500
Received: by mail-we0-f170.google.com with SMTP id w61so3542014wes.15
        for <netdev@vger.kernel.org>; Mon, 03 Mar 2014 08:49:07 -0800 (PST)
Received: from alyakaslap ([212.143.144.103])
        by mx.google.com with ESMTPSA id z1sm38040965wjq.19.2014.03.03.08.49.05
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 03 Mar 2014 08:49:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings all,
We are using bonding interfaces in active-backup (1) mode, with 
"fail_over_mac" set to "active" (1), with miimon=100 and two slaves. The 
slaves are "either regular" network interfaces, or vlan interfaces created 
with "vconfig" over "regular" interfaces. One of the slaves is defined as 
primary. The purpose of this config is to ensure failover in case one of the 
interfaces dies. This config usually works as expected.

One scenario that doesn't work for us, is when link status of the active 
slave is up, but all the packets sent to it are dropped, e.g., because of
incorrect switch configuration. In that case bond failover doesn't happen. 
Can this scenario be addressed with bonding?

Thanks,
Alex.

I found a discussion, which looks relevant, labeled "How to check an 
inactive slave in a bond?" in 
http://www.spinics.net/lists/lartc/msg21434.html". But this discussion 
considers the inactive slave, while in my case, I would like to better 
handle problems with the active slave.
