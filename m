From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9] atl1: add napi to Atheros L1 NIC
Date: Sun, 15 Apr 2012 13:03:46 -0400 (EDT)
Message-ID: <20120415.130346.1822341707659142562.davem@davemloft.net>
References: <1334333394-38404-1-git-send-email-antonz@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jcliburn@gmail.com, csnook@redhat.com,
	khorenko@parallels.com
To: antonz@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37446 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755815Ab2DORDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Apr 2012 13:03:52 -0400
In-Reply-To: <1334333394-38404-1-git-send-email-antonz@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Zelenoff <antonz@parallels.com>
Date: Fri, 13 Apr 2012 20:09:45 +0400

> Added NAPI interface to the driver of Atheros L1 NIC.
> RX speed reported by iperf in TCP mode (with and without -N
> switch) improved by ~7 Mbps. In UDP mode the speed up is
> improved by ~4 Mbps.
> Also hard RX/TX rings processing with memory allocation in
> interrupt handlers is not very good idea. So, fixed this.
> 
> Note: thouse patches must be applied after patch, that fix
> kernel panic in this driver.
> Its subject is: "atl1: fix kernel panic in case of DMA errors"

Unfortunately this is bullshit.  These patches actually depend upon
that bug fix not being applied.  Look at the patches, they reference
and use the reset workqueue the bug fix removed.

Anyways, I sorted through all of these merge hassles, and fixed up the
off-by-one bug Ben spotted in patch #2 because I was tired of waiting
and didn't want these patches to just keep rotting in patchwork.
