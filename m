From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 2/2] be2net: csum, tso and rss steering
 offload support for VxLAN
Date: Wed, 26 Mar 2014 15:29:25 -0400 (EDT)
Message-ID: <20140326.152925.636540498299329092.davem@davemloft.net>
References: <1395755430-17451-1-git-send-email-sathya.perla@emulex.com>
	<1395755430-17451-3-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46114 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754744AbaCZT31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 15:29:27 -0400
In-Reply-To: <1395755430-17451-3-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Tue, 25 Mar 2014 19:20:30 +0530

> This patch mainly implements the add/del_vxlan_port() methods by invoking
> the needed FW cmds for supporting VxLAN offloads for Skyhawk-R.
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

I know Or Gerlitz mentioned sleeping and that's where this workqueue comes
from, but please I'd say to not add this if it's not necessary.

be_cmd_set_profile_config() runs with a BH spinlock held during it's
entirety, it will never sleep.

So please go back to what you were doing in the first revision of this
patch and submit the command synchronously rather than via a workqueue.

Thanks.
