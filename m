From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 05/12] net: Add ndo_fcoe_control to
 net_device_ops
Date: Fri, 14 Aug 2009 16:14:43 -0700 (PDT)
Message-ID: <20090814.161443.18892020.davem@davemloft.net>
References: <20090814223857.1640.26881.stgit@localhost.localdomain>
	<20090814224239.1640.74924.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	gospo@redhat.com, yi.zou@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090814224239.1640.74924.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 14 Aug 2009 15:42:39 -0700

> From: Yi Zou <yi.zou@intel.com>
> 
> Add ndo_fcoe_control to net_device_ops so the corresponding HW can initialize
> itself for FCoE traffic or clean up after FCoE traffic is done. This is
> expected to be called by the kernel FCoE stack upon receiving a request for
> creating an FCoE instance on the corresponding netdev interface. When
> implemented by the actual HW, the HW driver check the op code to perform
> corresponding initialization or clean up for FCoE. The initialization normally
> includes allocating extra queues for FCoE, setting corresponding HW registers
> for FCoE, indicating FCoE offload features via netdev, etc. The clean-up would
> include releasing the resources allocated for FCoE.
> 
> Currently, there are two defined op codes as NETDEV_FCOE_DISABLE and _ENABLE,
> for initialization and cleanup accordingly.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

And here is where I stop applying patches.  This is not the way
to do this.

Having a vague "_control" operation with command codes is almost
as bad as ioctl().

Instead, add explicit ->ndo_fcoe_enable() and ndo_fcoe_disable()
operations.

Any other "control" commands you would add would probably need
parameters, and then this method would be a tangled web of
misc parameter slots and an even more tangled web of semantics.

Please resubmit the rest of this series once this issue is corrected.

Thanks.
