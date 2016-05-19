From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net V2] tuntap: correctly wake up process during uninit
Date: Thu, 19 May 2016 04:25:04 -0700
Message-ID: <1463657104.18194.154.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1463636211-3573-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Xi Wang <xii@google.com>,
	"Michael S . Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463636211-3573-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-05-19 at 13:36 +0800, Jason Wang wrote:
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

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
