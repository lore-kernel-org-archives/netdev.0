From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/2] ixgbe: Do not return 0 in ixgbe_fcoe_ddp()
 upon FCP_RSP in DDP completion
Date: Thu, 13 Aug 2009 20:14:24 -0700 (PDT)
Message-ID: <20090813.201424.36467757.davem@davemloft.net>
References: <20090814000929.20911.77027.stgit@localhost.localdomain>
	<20090814000958.20911.72817.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, yi.zou@intel.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34462
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756097AbZHNDOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 23:14:14 -0400
In-Reply-To: <20090814000958.20911.72817.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 13 Aug 2009 17:09:58 -0700

> From: Yi Zou <yi.zou@intel.com>
> 
> We return the ddp->len in ixgbe_fcoe_ddp() to indicate the length of data that
> have been DDPed. However, it is possible that the length is 0, e.g., for SCSI
> READ, the FCP_RSP may come back w/ SCSI status 0x28 as Task Set Full with no FCP
> data for DDP. In ixgbe_fcoe_ddp(), we return 0 to indicate not passing DDPed
> packets to upper layer. Therefore in the case of ddp->len being 0 upon FCP_RSP,
> we do not want to return the 0 ddp->len as we want FCP_RSP to be always
> delivered to the upper layer. This patch fixes this bug by setting rc only if
> ddp->len is non-zero.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
