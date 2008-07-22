From: "Jon Smirl" <jonsmirl@gmail.com>
Subject: Re: netif_schedule and mpc5200_fec
Date: Tue, 22 Jul 2008 17:03:32 -0400
Message-ID: <9e4733910807221403g512f6e37s6722c7950f881224@mail.gmail.com>
References: <9e4733910807221247r38509c76uf625195b712a1145@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: ppc-dev <Linuxppc-dev@ozlabs.org>, netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:58555 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755904AbYGVVDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 17:03:33 -0400
Received: by yx-out-2324.google.com with SMTP id 8so393779yxm.1
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2008 14:03:32 -0700 (PDT)
In-Reply-To: <9e4733910807221247r38509c76uf625195b712a1145@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/22/08, Jon Smirl <jonsmirl@gmail.com> wrote:
> I just updated to linus/master and mpc5200_fec won't boot.

It does boot, but this badness looks like it is coming from this
patch. I don't know enough about networking to debug it.

jonsmirl@terra:~/fs/drivers/net$ git diff
8b9835108f68938a5f7e74fd2c0fc65da2abad92 fec_mpc52xx.c
diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index 329edd9..ae9ecb7 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -197,7 +197,7 @@ static void mpc52xx_fec_adjust_link(struct net_device *dev)
                if (priv->link == PHY_DOWN) {
                        new_state = 1;
                        priv->link = phydev->link;
-                       netif_schedule(dev);
+                       netif_tx_schedule_all(dev);
                        netif_carrier_on(dev);
                        netif_start_queue(dev);
                }
jonsmirl@terra:~/fs/drivers/net$


>
>  Guessing it is this patch but I haven't looked at it yet.
>
>  commit 263ba3204a434d0ca851e1321b31cd58376b86cb
>  Author: David S. Miller <davem@davemloft.net>
>  Date:   Tue Jul 15 03:47:41 2008 -0700
>
>     netdev: Convert all drivers away from netif_schedule().
>
>     They logically all want to trigger a schedule for all device
>     TX queues.
>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
>
>  Sending DHCP requests .<0>------------[ cut here ]------------
>  Badness at c01da570 [verbose debug info unavailable]
>  NIP: c01da570 LR: c015b31c CTR: c015b234
>  REGS: c382de70 TRAP: 0700   Not tainted  (2.6.26-efika)
>  MSR: 00029032 <EE,ME,IR,DR>  CR: 22000082  XER: 00000000
>  TASK = c3815000[4] 'events/0' THREAD: c382c000
>  GPR00: 00000001 c382df20 c3815000 c031e468 c38f25a0 00000000 00000000 00000000
>  GPR08: c382dfb4 c0330000 00000000 c031e468 3181b461 ffffffff 03ffe000 ffffffff
>  GPR16: 00000001 00000000 007ffc00 00000000 00000000 03ff8838 00000000 00000004
>  GPR24: 00000000 00000000 c032b46c c0330000 c38a2e00 00000001 c38f2780 c38f2400
>  NIP [c01da570] __netif_schedule+0x3c/0xac
>  LR [c015b31c] mpc52xx_fec_adjust_link+0xe8/0x194
>  Call Trace:
>  [c382df20] [c002eeb0] queue_work+0x58/0x6c (unreliable)
>  [c382df40] [c015b31c] mpc52xx_fec_adjust_link+0xe8/0x194
>  [c382df60] [c0158cd0] phy_state_machine+0xec/0x4e0
>  [c382df80] [c002eb0c] run_workqueue+0xb4/0x148
>  [c382dfa0] [c002f070] worker_thread+0x9c/0xb8
>  [c382dfd0] [c0032954] kthread+0x4c/0x88
>  [c382dff0] [c000f538] kernel_thread+0x44/0x60
>  Instruction dump:
>  7c6b1b78 3929e468 7f834800 39200002 90010024 38030024 bfa10014 40be0030
>  3d20c033 80099988 7c000034 5400d97e <0f000000> 2f800000 41be0054 38000001
>  PHY: f0003000:00 - Link is Up - 100/Full
>  ., OK
>
>
>
>  --
>  Jon Smirl
>  jonsmirl@gmail.com
>


-- 
Jon Smirl
jonsmirl@gmail.com
