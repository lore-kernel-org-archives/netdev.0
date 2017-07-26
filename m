From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] virtio-net: mark PM functions as
 __maybe_unused
Date: Tue, 25 Jul 2017 21:23:13 -0700 (PDT)
Message-ID: <20170725.212313.1074903864708351840.davem@davemloft.net>
References: <20170725153600.211694-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, jasowang@redhat.com, john.fastabend@gmail.com,
        willemb@google.com, bigeasy@linutronix.de, edumazet@google.com,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170725153600.211694-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 25 Jul 2017 17:35:50 +0200

> After removing the reset function, the freeze and restore functions
> are now unused when CONFIG_PM_SLEEP is disabled:
> 
> drivers/net/virtio_net.c:1881:12: error: 'virtnet_restore_up' defined but not used [-Werror=unused-function]
>  static int virtnet_restore_up(struct virtio_device *vdev)
> drivers/net/virtio_net.c:1859:13: error: 'virtnet_freeze_down' defined but not used [-Werror=unused-function]
>  static void virtnet_freeze_down(struct virtio_device *vdev)
> 
> A more robust way to do this is to remove the #ifdef around the callers
> and instead mark them as __maybe_unused. The compiler will now just
> silently drop the unused code.
> 
> Fixes: 4941d472bf95 ("virtio-net: do not reset during XDP set")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks.
