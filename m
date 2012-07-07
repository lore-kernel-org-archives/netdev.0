From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 00/10] net/mlx4: Add flow-steering support
Date: Sat, 07 Jul 2012 16:24:03 -0700 (PDT)
Message-ID: <20120707.162403.1088189272300801994.davem@davemloft.net>
References: <1341497030-1818-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland@kernel.org, yevgenyp@mellanox.com, oren@mellanox.com,
	netdev@vger.kernel.org, amirv@mellanox.com, hadarh@mellanox.co.il
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45978 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751438Ab2GGXYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jul 2012 19:24:04 -0400
In-Reply-To: <1341497030-1818-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu,  5 Jul 2012 17:03:40 +0300

> This patch series from Hadar adds code to manage L2/L3/L4 network 
> flow steering rules, a feature which is supported by the ConnectX-3 device.
> 
> The series is built as follows:
> 
> The first two patches deal with SRIOV resource tracker, whose mechanism 
> is changed to use red-black tree instead of radix tree. The reason for 
> this change is that the coming steering patches use flow IDs which are 64 
> bits in size, where radix tree keys can't be 64bit on 32bit architecture, 
> while RB tree can do that.
> 
> Patch #3 is little re-design of the Ethernet driver multicast attachments 
> flow to be more efficient and robust.
> 
> The fourth patch does a re-org of the checks that deal with the current 
> "older" steering modes such that we can easily add soon the new steering 
> mode and the code remains easy to manage.
> 
> Patch #5 adds the firmware commands for the new steering mode, which is 
> called "device managed flow steeering".
> 
> Patch 6 is the main patch of this series. It adds support for device-managed flow 
> steering all across the place. We had to have this patch also to touch the mlx4 
> IB driver, since the steering mode is global to the HCA -- so when being enabled, 
> multicast attachment calls done by the IB driver into the mlx4 core driver, 
> are now routed to the flow steering firmware commands whose API is a bit different, 
> something that the IB driver had to be aware to. Following that, the 7th patch 
> adds resource tracking for device-managed flow steering rules.
> 
> The 8th patch adds promiscuous mode support under device-managed flow steering,
> next, the 9th patch adds implementation for the ethtool APIs for attaching 
> L2/L3/L4 based flow steering rules, and the last patch adds support for drop 
> action through ethtool.

All applied, thanks.
