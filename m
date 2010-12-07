From: Menil Jean-Philippe <jean-philippe.menil@univ-nantes.fr>
Subject: Re: NET_NS: unregister_netdevice: waiting for lo to become free (adding
 ipv6 address to interface)
Date: Tue, 07 Dec 2010 11:40:56 +0100
Message-ID: <4CFE0F38.6040100@univ-nantes.fr>
References: <20100710235323.5336f627@xenia.leun.net>	<20100711192939.1c25dcaf@xenia.leun.net>	<20100804153543.56f6ecad@xenia.leun.net>	<20100804214618.GA6289@kroah.com>	<20100805001105.5a3453ed@xenia.leun.net>	<m1lj8l29zm.fsf@fess.ebiederm.org>	<20100805112538.60a46cb1@xenia.leun.net>	<m1y6clz8ta.fsf_-_@fess.ebiederm.org>	<20100805134707.0442a7b1@xenia.leun.net>	<20101021171532.54af5e97@xenia.leun.net>	<20101022124858.GA719746@jupiter.n2.diac24.net>	<20101022190532.00e9e5d8@xenia.leun.net>	<20101024151541.161bf46c@xenia.leun.net>	<4CFD0A8F.8010906@univ-nantes.fr>	<m11v5uk35z.fsf@fess.ebiederm.org> <20101206234725.622a2212@xenia.leun.net>
Reply-To: jean-philippe.menil@univ-nantes.fr
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060701070208070705090602"
Cc: Michael Leun <lkml20100708@newton.leun.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	David Lamparter <equinox@diac24.net>, Greg KH <greg@kroah.com>,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101206234725.622a2212@xenia.leun.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060701070208070705090602
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 8bit

Le 06/12/2010 23:47, Michael Leun a écrit :
> On Mon, 06 Dec 2010 13:22:00 -0800
> ebiederm@xmission.com (Eric W. Biederman) wrote:
>
>> Menil Jean-Philippe<jean-philippe.menil@univ-nantes.fr>  writes:
>>
>>> Le 24/10/2010 15:15, Michael Leun a écrit :
>>>> On Fri, 22 Oct 2010 19:05:32 +0200
>>>> Michael Leun<lkml20100708@newton.leun.net>   wrote:
>>>>
>>>>> On Fri, 22 Oct 2010 14:48:58 +0200
>>>>> David Lamparter<equinox@diac24.net>   wrote:
>>>>>
>>>>>> On Thu, Oct 21, 2010 at 05:15:32PM +0200, Michael Leun wrote:
>>>>>>> unfortunately the bug described below originally reported in
>>>>>>> 2.6.35-rcX is still there in 2.6.36.
> [...]
>>> curiously, i'm facing a similar problem in 2.6.36.1
>>>
>>> in my container, when i configure ipv6 adress on the interfaces,
>>> everything seems good on the first boot of the host. If i shutdown
>>> my container (lxc), then boot it, i observe the following logs:
>>> Dec  6 17:04:12 suntory.u06.univ-nantes.prive kernel: [  368.192019]
>>> unregister_netdevice: waiting for lo to become free. Usage count = 4
>>> Dec  6 17:04:22 suntory.u06.univ-nantes.prive kernel: [  378.432018]
>>> unregister_netdevice: waiting for lo to become free. Usage count = 4
>>> Dec  6 17:04:32 suntory.u06.univ-nantes.prive kernel: [  388.672015]
>>> unregister_netdevice: waiting for lo to become free. Usage count = 4
>>> Dec  6 17:04:42 suntory.u06.univ-nantes.prive kernel: [  398.912016]
>>> unregister_netdevice: waiting for lo to become free. Usage count = 4
>>> Dec  6 17:04:53 suntory.u06.univ-nantes.prive kernel: [  409.152016]
>>> unregister_netdevice: waiting for lo to become free. Usage count = 4
>>> Dec  6 17:05:03 suntory.u06.univ-nantes.prive kernel: [  419.392018]
>>> unregister_netdevice: waiting for lo to become free. Usage count = 4
>>> Dec  6 17:05:13 suntory.u06.univ-nantes.prive kernel: [  429.632018]
>>> unregister_netdevice: waiting for lo to become free. Usage count = 4
>>> Dec  6 17:05:23 suntory.u06.univ-nantes.prive kernel: [  439.876016]
>>> unregister_netdevice: waiting for lo to become free. Usage count = 4
>>> Dec  6 17:05:34 suntory.u06.univ-nantes.prive kernel: [  450.116015]
>>> unregister_netdevice: waiting for lo to become free. Usage count = 4
>>> Dec  6 17:05:44 suntory.u06.univ-nantes.prive kernel: [  460.356019]
>>> unregister_netdevice: waiting for lo to become free. Usage count = 4
>>> Dec  6 17:05:54 suntory.u06.univ-nantes.prive kernel: [  470.596020]
>>> unregister_netdevice: waiting for lo to become free. Usage count = 4
>>> Dec  6 17:06:04 suntory.u06.univ-nantes.prive kernel: [  480.836019]
>>> unregister_netdevice: waiting for lo to become free. Usage count = 4
>>> Dec  6 17:06:05 suntory.u06.univ-nantes.prive kernel:
>>> [  481.468021] INFO: task lxc-start:3805 blocked for more than 120
>>> seconds.
>>>
>>> Then i must reboot the host.
>>> The same on kernel 2.6.34, but everything is good on a 2.6.32
>>>
>>> Some relvant informations about the kernel:
>>> root@suntory:~# cat /boot/config-2.6.36.1-dsiun-1d | grep -i sysfs
>>> # CONFIG_SYSFS_DEPRECATED_V2 is not set
>>> CONFIG_ACPI_SYSFS_POWER=y
>>> # CONFIG_WIRELESS_EXT_SYSFS is not set
>>> CONFIG_ISCSI_BOOT_SYSFS=m
>>> CONFIG_RTC_INTF_SYSFS=y
>>> CONFIG_SYSFS=y
>>> root@suntory:~# cat /boot/config-2.6.36.1-dsiun-1d | grep -i net_ns
>>> CONFIG_NET_NS=y
>>>
>>> Is there anything in my configuration, i must check in order to get
>>> ipv6 working fully in the container?
>>
>> 2.6.37-rc4 is working here.  There were problems earlier in the
>> earlier rcs. Can you try that?
>>
>> There have been a couple of different reference counting bugs between
>> 2.6.34 and the present, and I haven't tracked them, just noticed they
>> exist.
>
> Can reproduce the following still on 2.6.36.1, but NOT on 2.6.37-rc4 -
> so indeed seems to be fixed!
>
>
> Putting an ipv6 address on a device seems to be the trigger:
>
> OrigNS>  # ip link add type veth
> OrigNS>  # ip link set dev veth0 up
> OrigNS>  # unshare -n /bin/bash
> NewNS>  # echo $$
> <SomePID>
> OrigNS>  # ip link set dev veth1 netns<SomePID>  # this, of course is
> on a different terminal NewNS>  # ip link set dev veth1 up
> NewNS>  # ip -6 addr add dev veth1 fd50:dead:beef::1/64
> NewNS>  # exit
>
> Yields
>
> kernel: unregister_netdevice: waiting for veth1 to become free. Usage
> count = 3
>
>
Hi,

thanks for the info.

Unfortunately, i have another error with a kernel 2.6.37-rc5, already 
related to iov6

Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.803477] 
------------[ cut here ]------------
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.803554] 
WARNING: at net/ipv6/ip6_fib.c:1172 fib6_del+0x3e/0x2ce [ipv6]()
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.803616] 
Hardware name: PowerEdge M605
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.803673] 
Modules linked in: ipt_MASQUERADE iptable_nat nf_nat ipt_REJECT veth 
fuse xt_physdev ip6t_LOG ip6table_filter ip6_tables ipt_LOG xt_multiport 
xt_limit xt_tcpudp xt_state iptable_filter ip_tables x_tables 
nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4 
8021q bridge stp ext2 mbcache dm_round_robin dm_multipath 
nf_conntrack_ipv6 nf_conntrack nf_defrag_ipv6 ipv6 snd_pcm snd_timer snd 
soundcore snd_page_alloc tpm_tis tpm psmouse tpm_bios i2c_nforce2 pcspkr 
shpchp serio_raw pci_hotplug i2c_core button joydev ghes hed evdev 
dcdbas processor thermal_sys xfs exportfs dm_mod btrfs zlib_deflate 
crc32c libcrc32c sg sr_mod cdrom usbhid hid usb_storage ses sd_mod 
enclosure megaraid_sas lpfc ohci_hcd scsi_transport_fc scsi_tgt scsi_mod 
bnx2 ehci_hcd [last unloaded: scsi_wait_scan]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.806871] 
Pid: 5, comm: kworker/u:0 Not tainted 2.6.37-rc5-dsiun-1a #2
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.806931] 
Call Trace:
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.806991] 
[<ffffffff81040f56>] ? warn_slowpath_common+0x78/0x8c
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.807057] 
[<ffffffffa02df719>] ? fib6_del+0x3e/0x2ce [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.807118] 
[<ffffffff812d69c8>] ? schedule+0x79d/0x846
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.807182] 
[<ffffffffa02df9ed>] ? fib6_clean_node+0x44/0x96 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.807247] 
[<ffffffffa02db04b>] ? fib6_ifdown+0x0/0x21 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.807311] 
[<ffffffffa02dee56>] ? fib6_walk_continue+0xaa/0x12d [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.807377] 
[<ffffffffa02def2a>] ? fib6_walk+0x51/0xa4 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.807441] 
[<ffffffffa02df006>] ? fib6_clean_all+0x89/0xb7 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.807507] 
[<ffffffffa02df9a9>] ? fib6_clean_node+0x0/0x96 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.807572] 
[<ffffffffa02db04b>] ? fib6_ifdown+0x0/0x21 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.807636] 
[<ffffffffa02de76f>] ? rt6_ifdown+0x26/0x9f [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.807700] 
[<ffffffffa02d811a>] ? addrconf_ifdown+0x5b/0x441 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.807763] 
[<ffffffff812d81ba>] ? _raw_write_lock_bh+0xe/0x26
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.807827] 
[<ffffffffa02d8e94>] ? addrconf_notify+0x6eb/0x78d [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.807892] 
[<ffffffffa02df9a9>] ? fib6_clean_node+0x0/0x96 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.807957] 
[<ffffffffa02de7fb>] ? fib6_age+0x0/0x68 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.808031] 
[<ffffffff8105ea16>] ? notifier_call_chain+0x2e/0x5b
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.808096] 
[<ffffffff812544d6>] ? dev_close+0x31/0x35
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.808155] 
[<ffffffff81254598>] ? rollback_registered_many+0xbe/0x1fa
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.808218] 
[<ffffffff812546e2>] ? unregister_netdevice_many+0xe/0x62
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.808280] 
[<ffffffff81254892>] ? default_device_exit_batch+0x9e/0xb0
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.808342] 
[<ffffffff8124eed8>] ? cleanup_net+0x0/0x190
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.808401] 
[<ffffffff8124efcf>] ? cleanup_net+0xf7/0x190
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.808461] 
[<ffffffff8105752b>] ? process_one_work+0x250/0x3ce
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.808521] 
[<ffffffff81057a4c>] ? worker_thread+0x1cf/0x34b
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.808582] 
[<ffffffff8102f5a5>] ? __wake_up_common+0x41/0x78
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.808642] 
[<ffffffff8105787d>] ? worker_thread+0x0/0x34b
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.808701] 
[<ffffffff8105787d>] ? worker_thread+0x0/0x34b
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.808761] 
[<ffffffff8105a616>] ? kthread+0x7a/0x82
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.808822] 
[<ffffffff810037a4>] ? kernel_thread_helper+0x4/0x10
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.808882] 
[<ffffffff8105a59c>] ? kthread+0x0/0x82
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.808941] 
[<ffffffff810037a0>] ? kernel_thread_helper+0x0/0x10
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.809001] 
---[ end trace 3cbd5a9c87888acb ]---
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.809058] 
fib6_clean_node: del failed: rt=ffff88045e923680@ffff88045d52dd00 err=-2
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.809061] 
------------[ cut here ]------------
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.809123] 
WARNING: at net/ipv6/ip6_fib.c:1172 fib6_del+0x3e/0x2ce [ipv6]()
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.809184] 
Hardware name: PowerEdge M605
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.809240] 
Modules linked in: ipt_MASQUERADE iptable_nat nf_nat ipt_REJECT veth 
fuse xt_physdev ip6t_LOG ip6table_filter ip6_tables ipt_LOG xt_multiport 
xt_limit xt_tcpudp xt_state iptable_filter ip_tables x_tables 
nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4 
8021q bridge stp ext2 mbcache dm_round_robin dm_multipath 
nf_conntrack_ipv6 nf_conntrack nf_defrag_ipv6 ipv6 snd_pcm snd_timer snd 
soundcore snd_page_alloc tpm_tis tpm psmouse tpm_bios i2c_nforce2 pcspkr 
shpchp serio_raw pci_hotplug i2c_core button joydev ghes hed evdev 
dcdbas processor thermal_sys xfs exportfs dm_mod btrfs zlib_deflate 
crc32c libcrc32c sg sr_mod cdrom usbhid hid usb_storage ses sd_mod 
enclosure megaraid_sas lpfc ohci_hcd scsi_transport_fc scsi_tgt scsi_mod 
bnx2 ehci_hcd [last unloaded: scsi_wait_scan]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.812440] 
Pid: 5, comm: kworker/u:0 Tainted: G        W   2.6.37-rc5-dsiun-1a #2
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.812515] 
Call Trace:
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.812570] 
[<ffffffff81040f56>] ? warn_slowpath_common+0x78/0x8c
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.812635] 
[<ffffffffa02df719>] ? fib6_del+0x3e/0x2ce [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.812695] 
[<ffffffff812d5e6f>] ? printk+0x40/0x49
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.812758] 
[<ffffffffa02df9ed>] ? fib6_clean_node+0x44/0x96 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.812823] 
[<ffffffffa02db04b>] ? fib6_ifdown+0x0/0x21 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.812887] 
[<ffffffffa02dee56>] ? fib6_walk_continue+0xaa/0x12d [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.812953] 
[<ffffffffa02def2a>] ? fib6_walk+0x51/0xa4 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.813017] 
[<ffffffffa02df006>] ? fib6_clean_all+0x89/0xb7 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.813083] 
[<ffffffffa02df9a9>] ? fib6_clean_node+0x0/0x96 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.813147] 
[<ffffffffa02db04b>] ? fib6_ifdown+0x0/0x21 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.813212] 
[<ffffffffa02de76f>] ? rt6_ifdown+0x26/0x9f [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.813276] 
[<ffffffffa02d811a>] ? addrconf_ifdown+0x5b/0x441 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.813337] 
[<ffffffff812d81ba>] ? _raw_write_lock_bh+0xe/0x26
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.813401] 
[<ffffffffa02d8e94>] ? addrconf_notify+0x6eb/0x78d [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.813467] 
[<ffffffffa02df9a9>] ? fib6_clean_node+0x0/0x96 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.813532] 
[<ffffffffa02de7fb>] ? fib6_age+0x0/0x68 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.813592] 
[<ffffffff8105ea16>] ? notifier_call_chain+0x2e/0x5b
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.813653] 
[<ffffffff812544d6>] ? dev_close+0x31/0x35
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.813713] 
[<ffffffff81254598>] ? rollback_registered_many+0xbe/0x1fa
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.813775] 
[<ffffffff812546e2>] ? unregister_netdevice_many+0xe/0x62
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.813836] 
[<ffffffff81254892>] ? default_device_exit_batch+0x9e/0xb0
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.813898] 
[<ffffffff8124eed8>] ? cleanup_net+0x0/0x190
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.813957] 
[<ffffffff8124efcf>] ? cleanup_net+0xf7/0x190
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.814017] 
[<ffffffff8105752b>] ? process_one_work+0x250/0x3ce
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.819101] 
[<ffffffff81057a4c>] ? worker_thread+0x1cf/0x34b
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.819161] 
[<ffffffff8102f5a5>] ? __wake_up_common+0x41/0x78
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.819221] 
[<ffffffff8105787d>] ? worker_thread+0x0/0x34b
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.819281] 
[<ffffffff8105787d>] ? worker_thread+0x0/0x34b
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.819341] 
[<ffffffff8105a616>] ? kthread+0x7a/0x82
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.819400] 
[<ffffffff810037a4>] ? kernel_thread_helper+0x4/0x10
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.819461] 
[<ffffffff8105a59c>] ? kthread+0x0/0x82
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.819519] 
[<ffffffff810037a0>] ? kernel_thread_helper+0x0/0x10
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.819579] 
---[ end trace 3cbd5a9c87888acc ]---
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.819636] 
fib6_clean_node: del failed: rt=ffff88045e923900@ffff88085dc30380 err=-2
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.838291] 
------------[ cut here ]------------
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.838360] 
WARNING: at net/ipv6/ip6_fib.c:1172 fib6_del+0x3e/0x2ce [ipv6]()
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.838421] 
Hardware name: PowerEdge M605
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.838477] 
Modules linked in: ipt_MASQUERADE iptable_nat nf_nat ipt_REJECT veth 
fuse xt_physdev ip6t_LOG ip6table_filter ip6_tables ipt_LOG xt_multiport 
xt_limit xt_tcpudp xt_state iptable_filter ip_tables x_tables 
nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4 
8021q bridge stp ext2 mbcache dm_round_robin dm_multipath 
nf_conntrack_ipv6 nf_conntrack nf_defrag_ipv6 ipv6 snd_pcm snd_timer snd 
soundcore snd_page_alloc tpm_tis tpm psmouse tpm_bios i2c_nforce2 pcspkr 
shpchp serio_raw pci_hotplug i2c_core button joydev ghes hed evdev 
dcdbas processor thermal_sys xfs exportfs dm_mod btrfs zlib_deflate 
crc32c libcrc32c sg sr_mod cdrom usbhid hid usb_storage ses sd_mod 
enclosure megaraid_sas lpfc ohci_hcd scsi_transport_fc scsi_tgt scsi_mod 
bnx2 ehci_hcd [last unloaded: scsi_wait_scan]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.841677] 
Pid: 5, comm: kworker/u:0 Tainted: G        W   2.6.37-rc5-dsiun-1a #2
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.841752] 
Call Trace:
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.841809] 
[<ffffffff81040f56>] ? warn_slowpath_common+0x78/0x8c
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.841874] 
[<ffffffffa02df719>] ? fib6_del+0x3e/0x2ce [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.841936] 
[<ffffffff81271900>] ? netlink_broadcast_filtered+0x369/0x399
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.842003] 
[<ffffffffa02ed4b7>] ? igmp6_group_dropped+0x222/0x231 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.842069] 
[<ffffffffa02dbc00>] ? __ip6_del_rt+0x47/0x66 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.842133] 
[<ffffffffa02dbd69>] ? ip6_del_rt+0x2e/0x33 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.842197] 
[<ffffffffa02d68b0>] ? __ipv6_ifa_notify+0x156/0x19d [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.842263] 
[<ffffffffa02d840e>] ? addrconf_ifdown+0x34f/0x441 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.842328] 
[<ffffffffa02d8e94>] ? addrconf_notify+0x6eb/0x78d [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.842390] 
[<ffffffff8104d5bd>] ? try_to_del_timer_sync+0xab/0xb4
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.842451] 
[<ffffffff81249a96>] ? skb_dequeue+0x54/0x5c
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.842515] 
[<ffffffffa02f7d54>] ? ip6mr_device_event+0xa2/0xb3 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.842577] 
[<ffffffff8105ea16>] ? notifier_call_chain+0x2e/0x5b
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.842639] 
[<ffffffff812545ee>] ? rollback_registered_many+0x114/0x1fa
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.842701] 
[<ffffffff812546e2>] ? unregister_netdevice_many+0xe/0x62
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.842763] 
[<ffffffff81254892>] ? default_device_exit_batch+0x9e/0xb0
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.842824] 
[<ffffffff8124eed8>] ? cleanup_net+0x0/0x190
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.842883] 
[<ffffffff8124efcf>] ? cleanup_net+0xf7/0x190
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.842943] 
[<ffffffff8105752b>] ? process_one_work+0x250/0x3ce
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.843003] 
[<ffffffff81057a4c>] ? worker_thread+0x1cf/0x34b
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.843064] 
[<ffffffff8102f5a5>] ? __wake_up_common+0x41/0x78
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.843124] 
[<ffffffff8105787d>] ? worker_thread+0x0/0x34b
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.843183] 
[<ffffffff8105787d>] ? worker_thread+0x0/0x34b
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.843243] 
[<ffffffff8105a616>] ? kthread+0x7a/0x82
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.843302] 
[<ffffffff810037a4>] ? kernel_thread_helper+0x4/0x10
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.843363] 
[<ffffffff8105a59c>] ? kthread+0x0/0x82
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.843421] 
[<ffffffff810037a0>] ? kernel_thread_helper+0x0/0x10
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.843481] 
---[ end trace 3cbd5a9c87888acd ]---
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.843629] 
V2002: port 2(dns2-lmb-serv) entering disabled state
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.846285] 
------------[ cut here ]------------
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.846352] 
WARNING: at net/ipv6/ip6_fib.c:1172 fib6_del+0x3e/0x2ce [ipv6]()
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.846414] 
Hardware name: PowerEdge M605
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.846469] 
Modules linked in: ipt_MASQUERADE iptable_nat nf_nat ipt_REJECT veth 
fuse xt_physdev ip6t_LOG ip6table_filter ip6_tables ipt_LOG xt_multiport 
xt_limit xt_tcpudp xt_state iptable_filter ip_tables x_tables 
nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4 
8021q bridge stp ext2 mbcache dm_round_robin dm_multipath 
nf_conntrack_ipv6 nf_conntrack nf_defrag_ipv6 ipv6 snd_pcm snd_timer snd 
soundcore snd_page_alloc tpm_tis tpm psmouse tpm_bios i2c_nforce2 pcspkr 
shpchp serio_raw pci_hotplug i2c_core button joydev ghes hed evdev 
dcdbas processor thermal_sys xfs exportfs dm_mod btrfs zlib_deflate 
crc32c libcrc32c sg sr_mod cdrom usbhid hid usb_storage ses sd_mod 
enclosure megaraid_sas lpfc ohci_hcd scsi_transport_fc scsi_tgt scsi_mod 
bnx2 ehci_hcd [last unloaded: scsi_wait_scan]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.849680] 
Pid: 5, comm: kworker/u:0 Tainted: G        W   2.6.37-rc5-dsiun-1a #2
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.849755] 
Call Trace:
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.849813] 
[<ffffffff81040f56>] ? warn_slowpath_common+0x78/0x8c
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.849878] 
[<ffffffffa02df719>] ? fib6_del+0x3e/0x2ce [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.849940] 
[<ffffffff81271900>] ? netlink_broadcast_filtered+0x369/0x399
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.850007] 
[<ffffffffa02ed4b7>] ? igmp6_group_dropped+0x222/0x231 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.850073] 
[<ffffffffa02dbc00>] ? __ip6_del_rt+0x47/0x66 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.850137] 
[<ffffffffa02dbd69>] ? ip6_del_rt+0x2e/0x33 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.850201] 
[<ffffffffa02d68b0>] ? __ipv6_ifa_notify+0x156/0x19d [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.850267] 
[<ffffffffa02d840e>] ? addrconf_ifdown+0x34f/0x441 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.850332] 
[<ffffffffa02d8e94>] ? addrconf_notify+0x6eb/0x78d [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.850395] 
[<ffffffff8104d5bd>] ? try_to_del_timer_sync+0xab/0xb4
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.850456] 
[<ffffffff81249a96>] ? skb_dequeue+0x54/0x5c
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.850520] 
[<ffffffffa02f7d54>] ? ip6mr_device_event+0xa2/0xb3 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.850582] 
[<ffffffff8105ea16>] ? notifier_call_chain+0x2e/0x5b
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.850644] 
[<ffffffff812545ee>] ? rollback_registered_many+0x114/0x1fa
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.850706] 
[<ffffffff812546e2>] ? unregister_netdevice_many+0xe/0x62
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.850768] 
[<ffffffff81254892>] ? default_device_exit_batch+0x9e/0xb0
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.850830] 
[<ffffffff8124eed8>] ? cleanup_net+0x0/0x190
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.850889] 
[<ffffffff8124efcf>] ? cleanup_net+0xf7/0x190
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.850949] 
[<ffffffff8105752b>] ? process_one_work+0x250/0x3ce
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.851009] 
[<ffffffff81057a4c>] ? worker_thread+0x1cf/0x34b
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.851070] 
[<ffffffff8102f5a5>] ? __wake_up_common+0x41/0x78
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.851130] 
[<ffffffff8105787d>] ? worker_thread+0x0/0x34b
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.851189] 
[<ffffffff8105787d>] ? worker_thread+0x0/0x34b
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.851249] 
[<ffffffff8105a616>] ? kthread+0x7a/0x82
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.851308] 
[<ffffffff810037a4>] ? kernel_thread_helper+0x4/0x10
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.851369] 
[<ffffffff8105a59c>] ? kthread+0x0/0x82
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.851427] 
[<ffffffff810037a0>] ? kernel_thread_helper+0x0/0x10
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.851487] 
---[ end trace 3cbd5a9c87888ace ]---
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.851627] 
V2003: port 2(dns2-lmb-clus) entering disabled state
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.854386] 
------------[ cut here ]------------
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.854455] 
WARNING: at net/ipv6/ip6_fib.c:1172 fib6_del+0x3e/0x2ce [ipv6]()
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.854517] 
Hardware name: PowerEdge M605
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.854573] 
Modules linked in: ipt_MASQUERADE iptable_nat nf_nat ipt_REJECT veth 
fuse xt_physdev ip6t_LOG ip6table_filter ip6_tables ipt_LOG xt_multiport 
xt_limit xt_tcpudp xt_state iptable_filter ip_tables x_tables 
nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4 
8021q bridge stp ext2 mbcache dm_round_robin dm_multipath 
nf_conntrack_ipv6 nf_conntrack nf_defrag_ipv6 ipv6 snd_pcm snd_timer snd 
soundcore snd_page_alloc tpm_tis tpm psmouse tpm_bios i2c_nforce2 pcspkr 
shpchp serio_raw pci_hotplug i2c_core button joydev ghes hed evdev 
dcdbas processor thermal_sys xfs exportfs dm_mod btrfs zlib_deflate 
crc32c libcrc32c sg sr_mod cdrom usbhid hid usb_storage ses sd_mod 
enclosure megaraid_sas lpfc ohci_hcd scsi_transport_fc scsi_tgt scsi_mod 
bnx2 ehci_hcd [last unloaded: scsi_wait_scan]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.857801] 
Pid: 5, comm: kworker/u:0 Tainted: G        W   2.6.37-rc5-dsiun-1a #2
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.857876] 
Call Trace:
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.857934] 
[<ffffffff81040f56>] ? warn_slowpath_common+0x78/0x8c
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.857999] 
[<ffffffffa02df719>] ? fib6_del+0x3e/0x2ce [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.858060] 
[<ffffffff811fbe80>] ? extract_buf+0x76/0xc2
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.858124] 
[<ffffffffa02df9ed>] ? fib6_clean_node+0x44/0x96 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.858189] 
[<ffffffffa02db04b>] ? fib6_ifdown+0x0/0x21 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.858253] 
[<ffffffffa02dee56>] ? fib6_walk_continue+0xaa/0x12d [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.858319] 
[<ffffffffa02def2a>] ? fib6_walk+0x51/0xa4 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.858383] 
[<ffffffffa02df006>] ? fib6_clean_all+0x89/0xb7 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.858449] 
[<ffffffffa02df9a9>] ? fib6_clean_node+0x0/0x96 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.858514] 
[<ffffffffa02db04b>] ? fib6_ifdown+0x0/0x21 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.858578] 
[<ffffffffa02de76f>] ? rt6_ifdown+0x26/0x9f [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.858642] 
[<ffffffffa02d811a>] ? addrconf_ifdown+0x5b/0x441 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.858708] 
[<ffffffffa02d8e94>] ? addrconf_notify+0x6eb/0x78d [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.858770] 
[<ffffffff8104d5bd>] ? try_to_del_timer_sync+0xab/0xb4
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.858832] 
[<ffffffff81249a96>] ? skb_dequeue+0x54/0x5c
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.858896] 
[<ffffffffa02f7d54>] ? ip6mr_device_event+0xa2/0xb3 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.858959] 
[<ffffffff8105ea16>] ? notifier_call_chain+0x2e/0x5b
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.859021] 
[<ffffffff812545ee>] ? rollback_registered_many+0x114/0x1fa
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.859083] 
[<ffffffff812546e2>] ? unregister_netdevice_many+0xe/0x62
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.859145] 
[<ffffffff81254892>] ? default_device_exit_batch+0x9e/0xb0
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.859207] 
[<ffffffff8124eed8>] ? cleanup_net+0x0/0x190
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.859266] 
[<ffffffff8124efcf>] ? cleanup_net+0xf7/0x190
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.859326] 
[<ffffffff8105752b>] ? process_one_work+0x250/0x3ce
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.859386] 
[<ffffffff81057a4c>] ? worker_thread+0x1cf/0x34b
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.859447] 
[<ffffffff8102f5a5>] ? __wake_up_common+0x41/0x78
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.859507] 
[<ffffffff8105787d>] ? worker_thread+0x0/0x34b
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.859567] 
[<ffffffff8105787d>] ? worker_thread+0x0/0x34b
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.859627] 
[<ffffffff8105a616>] ? kthread+0x7a/0x82
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.859686] 
[<ffffffff810037a4>] ? kernel_thread_helper+0x4/0x10
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.859747] 
[<ffffffff8105a59c>] ? kthread+0x0/0x82
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.859805] 
[<ffffffff810037a0>] ? kernel_thread_helper+0x0/0x10
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.859865] 
---[ end trace 3cbd5a9c87888acf ]---
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.859923] 
fib6_clean_node: del failed: rt=ffff88045e923680@ffff88045d52dd00 err=-2
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.859925] 
------------[ cut here ]------------
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.859987] 
WARNING: at net/ipv6/ip6_fib.c:1172 fib6_del+0x3e/0x2ce [ipv6]()
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.860065] 
Hardware name: PowerEdge M605
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.860121] 
Modules linked in: ipt_MASQUERADE iptable_nat nf_nat ipt_REJECT veth 
fuse xt_physdev ip6t_LOG ip6table_filter ip6_tables ipt_LOG xt_multiport 
xt_limit xt_tcpudp xt_state iptable_filter ip_tables x_tables 
nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4 
8021q bridge stp ext2 mbcache dm_round_robin dm_multipath 
nf_conntrack_ipv6 nf_conntrack nf_defrag_ipv6 ipv6 snd_pcm snd_timer snd 
soundcore snd_page_alloc tpm_tis tpm psmouse tpm_bios i2c_nforce2 pcspkr 
shpchp serio_raw pci_hotplug i2c_core button joydev ghes hed evdev 
dcdbas processor thermal_sys xfs exportfs dm_mod btrfs zlib_deflate 
crc32c libcrc32c sg sr_mod cdrom usbhid hid usb_storage ses sd_mod 
enclosure megaraid_sas lpfc ohci_hcd scsi_transport_fc scsi_tgt scsi_mod 
bnx2 ehci_hcd [last unloaded: scsi_wait_scan]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.863303] 
Pid: 5, comm: kworker/u:0 Tainted: G        W   2.6.37-rc5-dsiun-1a #2
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.863378] 
Call Trace:
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.863433] 
[<ffffffff81040f56>] ? warn_slowpath_common+0x78/0x8c
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.863498] 
[<ffffffffa02df719>] ? fib6_del+0x3e/0x2ce [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.863559] 
[<ffffffff812d5e6f>] ? printk+0x40/0x49
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.863622] 
[<ffffffffa02df9ed>] ? fib6_clean_node+0x44/0x96 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.863686] 
[<ffffffffa02db04b>] ? fib6_ifdown+0x0/0x21 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.863751] 
[<ffffffffa02dee56>] ? fib6_walk_continue+0xaa/0x12d [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.863817] 
[<ffffffffa02def2a>] ? fib6_walk+0x51/0xa4 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.863881] 
[<ffffffffa02df006>] ? fib6_clean_all+0x89/0xb7 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.863946] 
[<ffffffffa02df9a9>] ? fib6_clean_node+0x0/0x96 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.864046] 
[<ffffffffa02db04b>] ? fib6_ifdown+0x0/0x21 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.864112] 
[<ffffffffa02de76f>] ? rt6_ifdown+0x26/0x9f [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.864177] 
[<ffffffffa02d811a>] ? addrconf_ifdown+0x5b/0x441 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.864242] 
[<ffffffffa02d8e94>] ? addrconf_notify+0x6eb/0x78d [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.864303] 
[<ffffffff8104d5bd>] ? try_to_del_timer_sync+0xab/0xb4
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.864364] 
[<ffffffff81249a96>] ? skb_dequeue+0x54/0x5c
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.869452] 
[<ffffffffa02f7d54>] ? ip6mr_device_event+0xa2/0xb3 [ipv6]
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.869515] 
[<ffffffff8105ea16>] ? notifier_call_chain+0x2e/0x5b
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.869577] 
[<ffffffff812545ee>] ? rollback_registered_many+0x114/0x1fa
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.869639] 
[<ffffffff812546e2>] ? unregister_netdevice_many+0xe/0x62
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.869701] 
[<ffffffff81254892>] ? default_device_exit_batch+0x9e/0xb0
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.869762] 
[<ffffffff8124eed8>] ? cleanup_net+0x0/0x190
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.869821] 
[<ffffffff8124efcf>] ? cleanup_net+0xf7/0x190
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.869881] 
[<ffffffff8105752b>] ? process_one_work+0x250/0x3ce
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.869941] 
[<ffffffff81057a4c>] ? worker_thread+0x1cf/0x34b
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.870001] 
[<ffffffff8102f5a5>] ? __wake_up_common+0x41/0x78
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.870061] 
[<ffffffff8105787d>] ? worker_thread+0x0/0x34b
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.870121] 
[<ffffffff8105787d>] ? worker_thread+0x0/0x34b
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.870180] 
[<ffffffff8105a616>] ? kthread+0x7a/0x82
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.870239] 
[<ffffffff810037a4>] ? kernel_thread_helper+0x4/0x10
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.870300] 
[<ffffffff8105a59c>] ? kthread+0x0/0x82
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.870358] 
[<ffffffff810037a0>] ? kernel_thread_helper+0x0/0x10
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.870418] 
---[ end trace 3cbd5a9c87888ad0 ]---
Dec  7 11:36:54 suntory.u06.univ-nantes.prive kernel: [ 1454.870476] 
fib6_clean_node: del failed: rt=ffff88045e923900@ffff88085dc30380 err=-2
Dec  7 11:36:59 suntory.u06.univ-nantes.prive kernel: [ 1459.702735] 
device dns2-lmb-clus entered promiscuous mode
Dec  7 11:36:59 suntory.u06.univ-nantes.prive kernel: [ 1459.704898] 
ADDRCONF(NETDEV_UP): dns2-lmb-clus: link is not ready
Dec  7 11:36:59 suntory.u06.univ-nantes.prive kernel: [ 1459.706711] 
device dns2-lmb-serv entered promiscuous mode
Dec  7 11:36:59 suntory.u06.univ-nantes.prive kernel: [ 1459.709079] 
ADDRCONF(NETDEV_UP): dns2-lmb-serv: link is not ready
Dec  7 11:37:04 suntory.u06.univ-nantes.prive kernel: [ 1465.152018] 
unregister_netdevice: waiting for eth1 to become free. Usage count = 1
Dec  7 11:37:15 suntory.u06.univ-nantes.prive kernel: [ 1475.392020] 
unregister_netdevice: waiting for eth1 to become free. Usage count = 1
Dec  7 11:37:25 suntory.u06.univ-nantes.prive kernel: [ 1485.632020] 
unregister_netdevice: waiting for eth1 to become free. Usage count = 1


I continue my tests.

thanks for your help.

Regards.

--------------060701070208070705090602
Content-Type: text/x-vcard; charset=utf-8;
 name="jean-philippe_menil.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="jean-philippe_menil.vcf"

begin:vcard
fn:Jean-Philippe Menil
n:Menil;Jean-Philippe
org;quoted-printable:Universit=C3=A9 de Nantes;IRTS
adr;quoted-printable:;;2 rue de la Houssini=C3=A8re;Nantes;;44322;France
email;internet:jean-philippe.menil@univ-nantes.fr
title:Reseau
tel;work:02 53 48 49 27
tel;fax:(33)2 51 12 58 60 
tel;cell:06 45 38 87 75
url:http://www.cri.univ-nantes.fr
version:2.1
end:vcard


--------------060701070208070705090602--
