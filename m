From: Charles Bueche <charles@bueche.ch>
Subject: Re: changing MTU on b44 breaks eth0
Date: Thu, 06 Nov 2003 23:02:44 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1068156163.3496.8.camel@bluez.bueche.ch>
References: <1067888106.3366.20.camel@bluez.bueche.ch>
	 <20031103205335.GA7668@ee.oulu.fi>
	 <20031103151618.79704b30.davem@redhat.com>
	 <20031104111555.GA26860@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Pietikainen <pp@ee.oulu.fi>
In-Reply-To: <20031104111555.GA26860@ee.oulu.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all,

sorry for the late answer. I tried to apply the patch mentionned below,
and it reject at Hunk #1. I run linux 2.4.22, my b44.c carry version
0.9.

Can you please send me the full b44.c file so I can try again ?

I'm a bit unsure wheter I should try anyway, your discussions are not
very understable to me. Pardon my ignorance of kernel dumps :-)

I would be very happy if I could simply recompile this particular
module, and not my full kernel after patching a single file. Is there a
way to find the commands originaly used to compile and link this module
from some logs ?

Regards,
Charles

On Tue, 2003-11-04 at 12:15, Pekka Pietikainen wrote:
> On Mon, Nov 03, 2003 at 03:16:18PM -0800, David S. Miller wrote:
> > I think Jeff should merge this upstrea, but I really disagree
> > with the CONFIG_PM ifdefs for the power-management support.
> Fine with me (patch with CONFIG_PM removed included)
> 
> Oh btw., when trying out whether the new code even compiles/loads
> I got the following in rmmod, does it look like something caused
> by generic code or should I look for a reason in b44? :-)
> (This is 2.6.0-test9-bk6).
> 
> kernel BUG at net/core/dev.c:2882!
> invalid operand: 0000 [#1]
> CPU:    0
> EIP:    0060:[<c024d66d>]    Tainted: P  
> EFLAGS: 00010297
> EIP is at free_netdev+0x2d/0x40
> eax: ddfd6800   ebx: ddfd6800   ecx: 1f2e9da0   edx: 00000003
> esi: dff5d000   edi: dff5d054   ebp: de743ec4   esp: de743ec4
> ds: 007b   es: 007b   ss: 0068
> Process rmmod (pid: 18966, threadinfo=de742000 task=c797b320)
> Stack: de743edc e090011d ddfd6800 dff5d000 e0902544 00000000 de743eec
> c01c8c09 
>        dff5d000 dff5d054 de743f04 c0210dd0 dff5d054 dff5d080 e0902590
> e0902590 
>        de743f18 c0210e02 dff5d054 e0902544 c02fb458 de743f2c c0211039
> e0902544 
> Call Trace:
>  [<e090011d>] b44_remove_one+0x3d/0x60 [b44]
>  [<c01c8c09>] pci_device_remove+0x39/0x40
>  [<c0210dd0>] device_release_driver+0x60/0x70
>  [<c0210e02>] driver_detach+0x22/0x40
>  [<c0211039>] bus_remove_driver+0x39/0x70
>  [<c0211434>] driver_unregister+0x14/0x26
>  [<c01c8dc7>] pci_unregister_driver+0x17/0x30
>  [<e09002c2>] b44_cleanup+0x12/0x14 [b44]
>  [<c0136313>] sys_delete_module+0x113/0x190
>  [<c014d8cf>] do_munmap+0x14f/0x1b0
>  [<c014d973>] sys_munmap+0x43/0x60
>  [<c010b2dd>] sysenter_past_esp+0x52/0x71
> 
> Code: 0f 0b 42 0b ab 48 2e c0 eb de c9 e9 93 6e ef ff 8d 76 00 55 
> 
> Trying to reproduce on a fresh non-nvidia-tainted -bk8 rmmod initially worked,
> then I did /sbin/modprobe b44; /sbin/ifup eth0; /sbin/rmmod b44
> managed to trigger another race:
> 
> eth0: no IPv6 routers present
> Unable to handle kernel paging request at virtual address 706647ef
>  printing eip:
> c0254415
> *pde = 00000000
> Oops: 0000 [#1]
> CPU:    0
> EIP:    0060:[<c0254415>]    Not tainted
> EFLAGS: 00010216
> EIP is at rtnetlink_fill_ifinfo+0x2a5/0x480
> eax: 706647e3   ebx: df037800   ecx: 00000ee4   edx: c68fa09c
> esi: 00000000   edi: df037805   ebp: dff8deb4   esp: dff8de88
> ds: 007b   es: 007b   ss: 0068
> Process events/0 (pid: 3, threadinfo=dff8c000 task=c151cc80)
> Stack: c689fd80 00000004 00000004 dff8dea4 00000ee4 00000f60 c68fa000
> 000005dc 
>        c689fd80 ffffffff 00000011 dff8dee4 c02548ac c689fd80 df037800
> 00000011 
>        00000000 00000000 ffffffff df037800 c0335c00 df037800 00000006
> dff8def8 
> Call Trace:
>  [<c02548ac>] rtmsg_ifinfo+0x5c/0xd0
>  [<c0254d95>] rtnetlink_event+0x35/0x62
>  [<c012e47d>] notifier_call_chain+0x2d/0x50
>  [<c024d580>] netdev_wait_allrefs+0xc0/0x110
>  [<c024d6dc>] netdev_run_todo+0x10c/0x1f0
>  [<c010a33f>] __down_failed+0xb/0x14
>  [<c013100b>] worker_thread+0x1bb/0x2a0
>  [<c0254fc0>] linkwatch_event+0x0/0x30
>  [<c011e410>] default_wake_function+0x0/0x30
>  [<c010b206>] ret_from_fork+0x6/0x14
>  [<c011e410>] default_wake_function+0x0/0x30
>  [<c0130e50>] worker_thread+0x0/0x2a0
>  [<c01092a9>] kernel_thread_helper+0x5/0xc
> 
> Code: 8b 50 0c b9 ff ff ff ff 31 c0 83 c2 08 89 d7 f2 ae f7 d1 49 
> 
> --- /usr/src/linux-2.6.0-0.test9.1.67/drivers/net/b44.c	2003-10-25 21:43:30.000000000 +0300
> +++ linux-2.6.0-test9/drivers/net/b44.c	2003-11-04 12:32:13.403426192 +0200
> @@ -25,8 +25,8 @@
>  
>  #define DRV_MODULE_NAME		"b44"
>  #define PFX DRV_MODULE_NAME	": "
> -#define DRV_MODULE_VERSION	"0.91"
> -#define DRV_MODULE_RELDATE	"Oct 3, 2003"
> +#define DRV_MODULE_VERSION	"0.92"
> +#define DRV_MODULE_RELDATE	"Nov 4, 2003"
>  
>  #define B44_DEF_MSG_ENABLE	  \
>  	(NETIF_MSG_DRV		| \
> @@ -942,6 +942,8 @@
>  	b44_init_hw(bp);
>  	spin_unlock_irq(&bp->lock);
>  
> +	b44_enable_ints(bp);
> +	
>  	return 0;
>  }
>  
> @@ -1558,6 +1560,8 @@
>  		netif_wake_queue(bp->dev);
>  		spin_unlock_irq(&bp->lock);
>  
> +		b44_enable_ints(bp);
> +		
>  		return 0;
>  	}
>  	case ETHTOOL_GPAUSEPARAM: {
> @@ -1601,6 +1605,8 @@
>  		}
>  		spin_unlock_irq(&bp->lock);
>  
> +		b44_enable_ints(bp);
> +		
>  		return 0;
>  	}
>  	};
> @@ -1852,11 +1858,53 @@
>  	}
>  }
>  
> +static int b44_suspend(struct pci_dev *pdev, u32 state)
> +{
> +	struct net_device *dev = pci_get_drvdata(pdev);
> +	struct b44 *bp = dev->priv;
> +
> +        if (!netif_running(dev))
> +                 return 0;
> +
> +	del_timer_sync(&bp->timer);
> +
> +	spin_lock_irq(&bp->lock); 
> +
> +	b44_halt(bp);
> +	netif_carrier_off(bp->dev); 
> +	netif_device_detach(bp->dev);
> +	b44_free_rings(bp);
> +
> +	spin_unlock_irq(&bp->lock);
> +	return 0;
> +}
> +
> +static int b44_resume(struct pci_dev *pdev)
> +{
> +	struct net_device *dev = pci_get_drvdata(pdev);
> +	struct b44 *bp = dev->priv;
> +
> +	if (!netif_running(dev))
> +		return 0;
> +
> +	spin_lock_irq(&bp->lock);
> +
> +	b44_init_rings(bp);
> +	b44_init_hw(bp);
> +	netif_device_attach(bp->dev);
> +	spin_unlock_irq(&bp->lock);
> +
> +	b44_enable_ints(bp);
> +	return 0;
> +}
> +
>  static struct pci_driver b44_driver = {
>  	.name		= DRV_MODULE_NAME,
>  	.id_table	= b44_pci_tbl,
>  	.probe		= b44_init_one,
>  	.remove		= __devexit_p(b44_remove_one),
> +        .suspend        = b44_suspend,
> +        .resume         = b44_resume,
>  };
>  
>  static int __init b44_init(void)
-- 
Charles Bueche <charles@bueche.ch>
sand, snow, wave, wind and net -surfer
