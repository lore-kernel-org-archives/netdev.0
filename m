From: Mason <slash.tmp@free.fr>
Subject: Re: Problem with PHY state machine when using interrupts
Date: Tue, 25 Jul 2017 12:51:55 +0200
Message-ID: <1c00935b-3a3c-4268-db99-a0487ddece76@free.fr>
References: <65b9f1f5-724c-cd03-1c39-59405e773efa@free.fr>
 <849513d9-c981-ec20-5a10-08c663d0aa37@free.fr>
 <02e9e171-ec22-e491-5bc8-ef4b3ad7fec2@gmail.com>
 <e6a7a5df-b735-6f9c-6a2b-cded86ec6525@free.fr>
 <b0410a73-ff2d-ca06-93fa-17af2040c41c@gmail.com>
 <0f56083f-d43e-a141-1470-b76546af6d58@gmail.com>
 <c81e12bc-0f89-5eab-547e-f0c1ec389ad8@free.fr>
 <62085f48-df18-f987-f521-dcdfbd7f574b@gmail.com>
 <eb09bda5-c972-0c2c-2693-982c02c8c87c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:20888 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750839AbdGYKwJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Jul 2017 06:52:09 -0400
In-Reply-To: <eb09bda5-c972-0c2c-2693-982c02c8c87c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/07/2017 00:39, Florian Fainelli wrote:

> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index d0626bf5c540..652e24b53f3f 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -968,6 +968,8 @@ void phy_stop(struct phy_device *phydev)
>          * of rtnl_lock(), but PHY_HALTED shall guarantee phy_change()
>          * will not reenable interrupts.
>          */
> +       if (phy_interrupt_is_valid(phydev))
> +               phy_change(phydev);
>  }
>  EXPORT_SYMBOL(phy_stop);
> 

When setting link down:
- kernel logs Unbalanced enable for IRQ 30 (PHY interrupt)
- serial console hangs

# ip link set eth0 up
[  125.800057] ENTER nb8800_tangox_reset
[  125.803790] ++ETH++ gw8  reg=f0026424 val=00
[  125.817446] ++ETH++ gw8  reg=f0026424 val=01
[  125.821768] ++ETH++ gw16 reg=f0026420 val=0050
[  125.826241] ENTER nb8800_hw_init
[  125.829507] ++ETH++ gw8  reg=f0026000 val=1c
[  125.833808] ++ETH++ gw8  reg=f0026001 val=05
[  125.838122] ++ETH++ gw8  reg=f0026004 val=22
[  125.842421] ++ETH++ gw8  reg=f0026008 val=04
[  125.846717] ++ETH++ gw8  reg=f0026014 val=0c
[  125.851015] ++ETH++ gw8  reg=f0026051 val=00
[  125.855310] ++ETH++ gw8  reg=f0026052 val=ff
[  125.859607] ++ETH++ gw8  reg=f0026054 val=40
[  125.863903] ++ETH++ gw8  reg=f0026060 val=00
[  125.868226] ++ETH++ gw8  reg=f0026061 val=c3
[  125.872534] ENTER nb8800_mc_init
[  125.875800] ++ETH++ gw8  reg=f002602e val=00
[  125.880096] ENTER nb8800_tangox_init
[  125.883697] ++ETH++ gw8  reg=f0026400 val=01
[  125.887993] ENTER nb8800_tango4_init
[  125.891592] ENTER nb8800_update_mac_addr
[  125.895538] ++ETH++ gw8  reg=f002606a val=00
[  125.899835] ++ETH++ gw8  reg=f002606b val=16
[  125.904132] ++ETH++ gw8  reg=f002606c val=e8
[  125.908429] ++ETH++ gw8  reg=f002606d val=5e
[  125.912725] ++ETH++ gw8  reg=f002606e val=65
[  125.917022] ++ETH++ gw8  reg=f002606f val=bc
[  125.921319] ++ETH++ gw8  reg=f002603c val=00
[  125.925618] ++ETH++ gw8  reg=f002603d val=16
[  125.929912] ++ETH++ gw8  reg=f002603e val=e8
[  125.934210] ++ETH++ gw8  reg=f002603f val=5e
[  125.938505] ++ETH++ gw8  reg=f0026040 val=65
[  125.942802] ++ETH++ gw8  reg=f0026041 val=bc
[  125.947095] ENTER nb8800_open
[  125.950082] ENTER nb8800_dma_init
[  125.954025] ++ETH++ gw8  reg=f0026004 val=23
[  125.958331] ++ETH++ gw8  reg=f0026000 val=1d
[  126.027848] ENTER nb8800_set_rx_mode
[  126.031451] ENTER nb8800_mc_init
[  126.034702] ++ETH++ gw8  reg=f002602e val=00
[  126.039334] Atheros 8035 ethernet 26000.nb8800-mii:04: PHY state change UP -> AN
[  126.046838] ENTER nb8800_set_rx_mode
[  126.050438] ENTER nb8800_mc_init
[  126.053688] ++ETH++ gw8  reg=f002602e val=00
[  126.057983] ++ETH++ gw8  reg=f0026028 val=01
[  126.062279] ++ETH++ gw8  reg=f0026029 val=00
[  126.066573] ++ETH++ gw8  reg=f002602a val=5e
[  126.070868] ++ETH++ gw8  reg=f002602b val=00
[  126.075162] ++ETH++ gw8  reg=f002602c val=00
[  126.079457] ++ETH++ gw8  reg=f002602d val=01
[  126.083751] ENTER nb8800_mc_init
[  126.086997] ++ETH++ gw8  reg=f002602e val=ff
[  129.426741] ENTER nb8800_link_reconfigure
[  129.430800] PRIV link=0 speed=0 duplex=0
[  129.434753] PHYDEV link=1 speed=1000 duplex=1
[  129.439141] ENTER nb8800_mac_config
[  129.442662] ++ETH++ gw8  reg=f0026050 val=01
[  129.446962] ++ETH++ gw8  reg=f002601c val=ff
[  129.451262] ++ETH++ gw8  reg=f0026044 val=81
[  129.455563] ENTER nb8800_pause_config
[  129.459252] ++ETH++ gw8  reg=f0026004 val=2b
[  129.463558] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
[  129.471355] Atheros 8035 ethernet 26000.nb8800-mii:04: PHY state change AN -> RUNNING


# ip link set eth0 down
[  170.933454] ENTER nb8800_set_rx_mode
[  170.937067] ENTER nb8800_mc_init
[  170.940318] ++ETH++ gw8  reg=f002602e val=00
[  170.944613] ++ETH++ gw8  reg=f0026028 val=01
[  170.948907] ++ETH++ gw8  reg=f0026029 val=00
[  170.953199] ++ETH++ gw8  reg=f002602a val=5e
[  170.957494] ++ETH++ gw8  reg=f002602b val=00
[  170.961786] ++ETH++ gw8  reg=f002602c val=00
[  170.966079] ++ETH++ gw8  reg=f002602d val=01
[  170.970371] ENTER nb8800_mc_init
[  170.973616] ++ETH++ gw8  reg=f002602e val=ff
[  170.977962] ENTER nb8800_stop
[  170.981210] ------------[ cut here ]------------
[  170.985860] WARNING: CPU: 0 PID: 964 at kernel/irq/manage.c:498 __enable_irq+0x44/0x68
[  170.993815] Unbalanced enable for IRQ 30
[  170.997751] Modules linked in:
[  171.000821] CPU: 0 PID: 964 Comm: ip Not tainted 4.13.0-rc1 #154
[  171.006854] Hardware name: Sigma Tango DT
[  171.010896] [<c010e88c>] (unwind_backtrace) from [<c010b014>] (show_stack+0x10/0x14)
[  171.018686] [<c010b014>] (show_stack) from [<c04ab694>] (dump_stack+0x78/0x8c)
[  171.025950] [<c04ab694>] (dump_stack) from [<c0118228>] (__warn+0xe8/0x100)
[  171.032948] [<c0118228>] (__warn) from [<c0118278>] (warn_slowpath_fmt+0x38/0x48)
[  171.040471] [<c0118278>] (warn_slowpath_fmt) from [<c015f0e4>] (__enable_irq+0x44/0x68)
[  171.048519] [<c015f0e4>] (__enable_irq) from [<c015f13c>] (enable_irq+0x34/0x6c)
[  171.055956] [<c015f13c>] (enable_irq) from [<c037fa84>] (phy_change+0x98/0x13c)                                                
[  171.063305] [<c037fa84>] (phy_change) from [<c037fc04>] (phy_stop+0x90/0x94)                                                   
[  171.070391] [<c037fc04>] (phy_stop) from [<c0385330>] (nb8800_stop+0x24/0x84)                                                  
[  171.077567] [<c0385330>] (nb8800_stop) from [<c03fcdb4>] (__dev_close_many+0x88/0xd0)                                          
[  171.085439] [<c03fcdb4>] (__dev_close_many) from [<c03fcf1c>] (__dev_close+0x24/0x38)                                          
[  171.093311] [<c03fcf1c>] (__dev_close) from [<c04058c4>] (__dev_change_flags+0x94/0x144)
[  171.101445] [<c04058c4>] (__dev_change_flags) from [<c040598c>] (dev_change_flags+0x18/0x48)
[  171.109929] [<c040598c>] (dev_change_flags) from [<c046aed0>] (devinet_ioctl+0x6e0/0x7a0)
[  171.118152] [<c046aed0>] (devinet_ioctl) from [<c046d360>] (inet_ioctl+0x194/0x1c0)
[  171.125852] [<c046d360>] (inet_ioctl) from [<c03e5d80>] (sock_ioctl+0x148/0x2fc)
[  171.133290] [<c03e5d80>] (sock_ioctl) from [<c01e25f0>] (do_vfs_ioctl+0x9c/0x8e8)
[  171.140814] [<c01e25f0>] (do_vfs_ioctl) from [<c01e2e70>] (SyS_ioctl+0x34/0x5c)
[  171.148162] [<c01e2e70>] (SyS_ioctl) from [<c01076c0>] (ret_fast_syscall+0x0/0x3c)
[  171.155769] ---[ end trace ac6e716156da6518 ]---
[  171.160498] ENTER nb8800_link_reconfigure
[  171.161322] ++ETH++ gw8  reg=f0026004 val=0b
[  171.161325] ++ETH++ gw8  reg=f0026044 val=85
[  171.173176] PRIV link=1 speed=1000 duplex=1
[  171.177388] PHYDEV link=0 speed=1000 duplex=1
[  171.181793] nb8800 26000.ethernet eth0: Link is Down
[  171.661513] ++ETH++ gw8  reg=f0026004 val=2b
[  171.665812] ++ETH++ gw8  reg=f0026044 val=81
[  171.670155] ++ETH++ gw8  reg=f0026004 val=2a
^C^C^C^C

Using SysRq to find *where* it hangs...

[  187.010561] NMI backtrace for cpu 1
[  187.010567] CPU: 1 PID: 964 Comm: ip Tainted: G        W       4.13.0-rc1 #154
[  187.010569] Hardware name: Sigma Tango DT
[  187.010571] task: deedb580 task.stack: ded7e000
[  187.010577] PC is at nb8800_mac_tx+0x4/0x54
[  187.010580] LR is at nb8800_stop+0x5c/0x84
[  187.010583] pc : [<c0383ba8>]    lr : [<c0385368>]    psr: 200f0013
...
[  187.010675] [<c010bb4c>] (__irq_svc) from [<c0383ba8>] (nb8800_mac_tx+0x4/0x54)
[  187.010684] [<c0383ba8>] (nb8800_mac_tx) from [<c03fcdb4>] (__dev_close_many+0x88/0xd0)
[  187.010691] [<c03fcdb4>] (__dev_close_many) from [<c03fcf1c>] (__dev_close+0x24/0x38)
[  187.010697] [<c03fcf1c>] (__dev_close) from [<c04058c4>] (__dev_change_flags+0x94/0x144)
[  187.010703] [<c04058c4>] (__dev_change_flags) from [<c040598c>] (dev_change_flags+0x18/0x48)
[  187.010710] [<c040598c>] (dev_change_flags) from [<c046aed0>] (devinet_ioctl+0x6e0/0x7a0)
[  187.010717] [<c046aed0>] (devinet_ioctl) from [<c046d360>] (inet_ioctl+0x194/0x1c0)
[  187.010725] [<c046d360>] (inet_ioctl) from [<c03e5d80>] (sock_ioctl+0x148/0x2fc)
[  187.010735] [<c03e5d80>] (sock_ioctl) from [<c01e25f0>] (do_vfs_ioctl+0x9c/0x8e8)
[  187.010743] [<c01e25f0>] (do_vfs_ioctl) from [<c01e2e70>] (SyS_ioctl+0x34/0x5c)
[  187.010749] [<c01e2e70>] (SyS_ioctl) from [<c01076c0>


I'm not sure that phy_change is supposed to be called from
process context?
/* phy_change - Called by the phy_interrupt to handle PHY changes */


Moving the call to phy_stop() down after all the MAC tear down
avoids the hang.

As far as I understand, when we are shutting everything down,
we don't need the phy_state_machine to run asynchronously.
We can run it synchronously one last time after the delayed
stuff has been disabled.

Regards.
