From: Pratyush Anand <pratyush.anand@st.com>
Subject: Re: Detected Hardware Unit Hang on Intel Wired Ethernet
Date: Wed, 4 Jan 2012 16:31:36 +0530
Message-ID: <4F043190.70405@st.com>
References: <CAHM4w1=i5dYy+ReqMO=m6W96CNaQ+O=jw+pKQok0nmjb5-fNAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Shiraz HASHIM <shiraz.hashim@st.com>,
	Deepak SIKRI <deepak.sikri@st.com>,
	Bhavna YADAV <bhavna.yadav@st.com>, <linux-pci@vger.kernel.org>
To: Pratyush Anand <pratyush.anand@gmail.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <CAHM4w1=i5dYy+ReqMO=m6W96CNaQ+O=jw+pKQok0nmjb5-fNAw@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adding PCI mailing list too, as problem is coming only when MSI is enabled.

If I connect an PCIe analyzer, I see that at the time of issue MRd(64) 
for 32 words has been issued with a wrong 64 bit address from ethernet 
card to my RC.
In the normal course it always issues MRd(32) only.

Regards
Pratyush

On 1/4/2012 3:18 PM, Pratyush Anand wrote:
> Hi All,
>
> I am trying to use PCIe based Intel PRO/1000 PT Server Adapter card on
> an ARM Corterx A-9 based platform.
> I am using linux 2.6.37.
>
> I am trying to mount my rootfile system on NFS using interface of this card.
>
> I see follwing issue while nfs mount
> ----------------------------------------------------------------------------------------------------------------------------------------------------------
> IP-Config: Complete:
>       device=eth0, addr=192.168.1.10, mask=255.255.255.0, gw=255.255.255.255,
>       host=192.168.1.10, domain=, nis-domain=(none),
>       bootserver=192.168.1.1, rootserver=192.168.1.1, rootpath=
> NFS:1. attempt to mount rootVFS: Mounted root (nfs filesystem) on device 0:13.
> Freeing init memory: 184K
> nfs: server 192.168.1.1 not responding, still trying
> e1000e 0000:03:00.0: eth0: Detected Hardware Unit Hang:
>    TDH<40>
>    TDT<43>
>    next_to_use<43>
>    next_to_clean<3f>
> buffer_info[next_to_clean]:
>    time_stamp<ffff984a>
>    next_to_watch<40>
>    jiffies<ffff9948>
>    next_to_watch.status<0>
> MAC Status<80383>
> PHY Status<792d>
> PHY 1000BASE-T Status<3800>
> PHY Extended Status<3000>
> PCI Status<4010>
> e1000e 0000:03:00.0: eth0: Detected Hardware Unit Hang:
>    TDH<40>
>    TDT<43>
>    next_to_use<43>
>    next_to_clean<3f>
> buffer_info[next_to_clean]:
>    time_stamp<ffff984a>
>    next_to_watch<40>
>    jiffies<ffff9a10>
>    next_to_watch.status<0>
> MAC Status<80383>
> PHY Status<792d>
> PHY 1000BASE-T Status<3800>
> PHY Extended Status<3000>
> PCI Status<4010>
> e1000e 0000:03:00.0: eth0: Detected Hardware Unit Hang:
>    TDH<40>
>    TDT<43>
>    next_to_use<43>
>    next_to_clean<3f>
> buffer_info[next_to_clean]:
>    time_stamp<ffff984a>
>    next_to_watch<40>
>    jiffies<ffff9ba0>
>    next_to_watch.status<0>
> MAC Status<80383>
> PHY Status<792d>
> PHY 1000BASE-T Status<3800>
> PHY Extended Status<3000>
> PCI Status<4010>
> e1000e 0000:03:00.0: eth0: Detected Hardware Unit Hang:
>    TDH<40>
>    TDT<43>
>    next_to_use<43>
>    next_to_clean<3f>
> buffer_info[next_to_clean]:
>    time_stamp<ffff984a>
>    next_to_watch<40>
>    jiffies<ffff9c68>
>    next_to_watch.status<0>
> MAC Status<80383>
> PHY Status<792d>
> PHY 1000BASE-T Status<3800>
> PHY Extended Status<3000>
> PCI Status<4010>
> ------------[ cut here ]------------
> WARNING: at /data/csd_sw/spear/drives_os/pratyusha/spear/kernel/linux-2.6/net/sched/sch_generic.c:258
> dev_watchdog+0x168/0x280()
> NETDEV WATCHDOG: eth0 (e1000e): transmit queue 0 timed out
> Modules linked in:
> Backtrace:
> [<8003f9fc>] (dump_backtrace+0x0/0x10c) from [<803ede3c>] (dump_stack+0x18/0x1c)
>   r6:804f3833 r5:00000102 r4:8e83dc18 r3:60000113
> [<803ede24>] (dump_stack+0x0/0x1c) from [<8005e2b8>]
> (warn_slowpath_common+0x54/0x6c)
> [<8005e264>] (warn_slowpath_common+0x0/0x6c) from [<8005e374>]
> (warn_slowpath_fmt+0x38/0x40)
>   r8:00000001 r7:00000000 r6:807164c0 r5:8eaf01d4 r4:8eaf0000
> r3:00000009
> [<8005e33c>] (warn_slowpath_fmt+0x0/0x40) from [<8036d7bc>]
> (dev_watchdog+0x168/0x280)
>   r3:8eaf0000 r2:804f3889
> [<8036d654>] (dev_watchdog+0x0/0x280) from [<80069680>]
> (run_timer_softirq+0x158/0x210)
> [<80069528>] (run_timer_softirq+0x0/0x210) from [<80063cb8>]
> (__do_softirq+0xb8/0x160)
>   r8:0000000a r7:00000100 r6:80525044 r5:00000141 r4:8e83c000
> [<80063c00>] (__do_softirq+0x0/0x160) from [<80064144>] (irq_exit+0x4c/0x54)
> [<800640f8>] (irq_exit+0x0/0x54) from [<80040e2c>] (ipi_timer+0x40/0x4c)
> [<80040dec>] (ipi_timer+0x0/0x4c) from [<80036260>] (do_local_timer+0x5c/0x88)
>   r4:800348b4 r3:00001179
> [<80036204>] (do_local_timer+0x0/0x88) from [<8003b714>] (__irq_svc+0x34/0xc0)
> Exception stack(0x8e83dd68 to 0x8e83ddb0)
> dd60:                   8054d648 60000093 8054d640 60000013 00000206 00000001
> dd80: 80585216 00000000 8054d5b8 8e83de3c 804ca994 8e83de1c 8e83dd88 8e83ddb0
> dda0: 8005f0b0 8005f588 60000013 ffffffff
>   r6:0000001d r5:fec80100 r4:ffffffff r3:60000013
> [<8005f1f4>] (vprintk+0x0/0x3f0) from [<803edfe0>] (printk+0x24/0x2c)
> [<803edfbc>] (printk+0x0/0x2c) from [<8020db74>] (__dev_printk+0x58/0x68)
>   r3:8e886dc0 r2:8056e0fc r1:804b70c9 r0:804ca994
> [<8020db1c>] (__dev_printk+0x0/0x68) from [<8020ddb0>] (dev_printk+0x34/0x3c)
>   r6:00000040 r5:ffff984a r4:8eaf0360
> [<8020dd7c>] (dev_printk+0x0/0x3c) from [<803589fc>] (__netdev_printk+0x4c/0x94)
>   r3:8eaf0000 r2:804ca999
> [<803589b0>] (__netdev_printk+0x0/0x94) from [<80358b58>] (netdev_err+0x3c/0x48)
>   r4:8eaf0360
> [<80358b1c>] (netdev_err+0x0/0x48) from [<8028cb34>]
> (e1000_print_hw_hang+0x124/0x134)
>   r3:00000043 r2:00000040 r1:804d85ab
> [<8028ca10>] (e1000_print_hw_hang+0x0/0x134) from [<80072d6c>]
> (process_one_work+0x1f0/0x324)
> [<80072b7c>] (process_one_work+0x0/0x324) from [<800733a4>]
> (worker_thread+0x1c0/0x300)
> [<800731e4>] (worker_thread+0x0/0x300) from [<80076e04>] (kthread+0x90/0x98)
> [<80076d74>] (kthread+0x0/0x98) from [<8006169c>] (do_exit+0x0/0x5f8)
>   r6:8006169c r5:80076d74 r4:8e831ee0
> ---[ end trace ea1efd5a579b2b9e ]---
> e1000e 0000:03:00.0: eth0: Reset adapter
> e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
> nfs: server 192.168.1.1 not responding, still trying
> nfs: server 192.168.1.1 not responding, still trying
> ----------------------------------------------------------------------------------------------------------------------------------------------------------
>
> However, If I pass pci=nomsi in bootargs then it works fine.
>
> I see similar issue discussed earlier at following link:
> http://sourceforge.net/tracker/index.php?func=detail&aid=2896629&group_id=42302&atid=447449
>
> Reading above link, it seems that bug should have been resolved in linux 2.6.32.
> But I still see it in 2.6.37.
> Any suggestion to resolve?
>
> Regards
> Pratyush
> .
>
