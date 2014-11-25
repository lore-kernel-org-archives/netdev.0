From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] bonding: move ipoib_header_ops to vmlinux
Date: Tue, 25 Nov 2014 01:07:41 -0500 (EST)
Message-ID: <20141125.010741.450666241983239119.davem@davemloft.net>
References: <1416893768-21369-1-git-send-email-wen.gang.wang@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: wen.gang.wang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1416893768-21369-1-git-send-email-wen.gang.wang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Wengang Wang <wen.gang.wang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Date: Tue, 25 Nov 2014 13:36:08 +0800

> When last slave of a bonding master is removed, the bonding then does not work.
> At the time if packet_snd is called against with a master net_device, it calls
> then header_ops->create which points to slave's header_ops. In case the slave
> is ipoib and the module is unloaded, header_ops would point to invalid address.
> Accessing it will cause problem.
> This patch tries to fix this issue by moving ipoib_header_ops to vmlinux to keep
> it valid even when ipoib module is unloaded.
> 
> Signed-off-by: Wengang Wang <wen.gang.wang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>

IPOIB should not work over bonding as it requires that the device
use ARPHRD_ETHER.

Someone mentioned this, and I did not see any response.

Please show how a legitimate real bonding configuration can be
created, reproduce a stray memory access, and therefore potentially
cause a crash.

Using various debugging features of the kernel should allow you to
trigger an assertion quite easily if this bug really exists.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
