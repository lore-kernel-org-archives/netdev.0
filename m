From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V2] tuntap: correctly wake up process during uninit
Date: Fri, 20 May 2016 19:38:06 -0400 (EDT)
Message-ID: <20160520.193806.543505636945844730.davem@davemloft.net>
References: <1463636211-3573-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	edumazet@google.com, xii@google.com, mst@redhat.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463636211-3573-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Thu, 19 May 2016 13:36:51 +0800

> We used to check dev->reg_state against NETREG_REGISTERED after each
> time we are woke up. But after commit 9e641bdcfa4e ("net-tun:
> restructure tun_do_read for better sleep/wakeup efficiency"), it uses
> skb_recv_datagram() which does not check dev->reg_state. This will
> result if we delete a tun/tap device after a process is blocked in the
> reading. The device will wait for the reference count which was held
> by that process for ever.
> 
> Fixes this by using RCV_SHUTDOWN which will be checked during
> sk_recv_datagram() before trying to wake up the process during uninit.
> 
> Fixes: 9e641bdcfa4e ("net-tun: restructure tun_do_read for better
> sleep/wakeup efficiency")
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Xi Wang <xii@google.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
> - The patch is needed for -stable.
> - Changes from v1: remove unnecessary NETREG_REGISTERED check in tun_do_read()

Applied and queued up for -stable.
