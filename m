From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] bonding: move ipoib_header_ops to vmlinux
Date: Mon, 29 Dec 2014 23:23:28 -0500 (EST)
Message-ID: <20141229.232328.1289919985601274661.davem@davemloft.net>
References: <1419908682-17012-1-git-send-email-wen.gang.wang@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: wen.gang.wang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1419908682-17012-1-git-send-email-wen.gang.wang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Wengang Wang <wen.gang.wang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Date: Tue, 30 Dec 2014 11:04:42 +0800

> When last slave of a bonding master is removed, the bonding then does not work.
> At the time if packet_snd is called against with a master net_device, it calls
> then header_ops->create which points to slave's header_ops. In case the slave
> is ipoib and the module is unloaded, header_ops would point to invalid address.
> Accessing it will cause problem.
> This patch tries to fix this issue by moving ipoib_header_ops to vmlinux to keep
> it valid even when ipoib module is unloaded.
> 
> Signed-off-by: Wengang Wang <wen.gang.wang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>

Like others, I absolutely do not consider it sustainable to keep
moving header_ops implementations into the static kernel image.

We're just papering over the real problem, which is making sure all
dangling references to something really go away when we release/unload
an object.

Point it to a dummy set of ops and do a synchronize_net() or similar.

I'm not applying this patch, sorry.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
