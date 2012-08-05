From: Bernard Pidoux <bernard.pidoux@free.fr>
Subject: Re: CPU: 0 Not tainted  (3.1.9+ #1) when ifconfig rose0 down
Date: Sun, 05 Aug 2012 18:23:25 +0200
Message-ID: <501E9DFD.4040301@free.fr>
References: <5017E786.5000102@free.fr> <87ipd0ykdg.fsf@xmission.com> <20120803143200.GE10211@belle.intranet.vanheusden.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	linux-hams <linux-hams@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: folkert <folkert@vanheusden.com>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20120803143200.GE10211@belle.intranet.vanheusden.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for suggesting a bissect. However I guess that this bug has 
always been there !

I am not professionaly involved in programming, however I committed a 
few patches for ROSE, AX.25 and NetRom modules since a few years.

I reactivated netconfig and here is the report showing that kernel panic 
occurs when rose_device_event is triggered when issuing command
ifconfig rose0 down

[ 1215.153302] rose_kill_by_device() rose->neighbour->use 0
[ 1215.153316] BUG: unable to handle kernel NULL pointer dereference at 
000000000000002a
[ 1215.153321] IP: [<ffffffffa065e37d>] rose_device_event+0x11d/0x160 [rose]
[ 1215.153333] PGD 36340067 PUD 359fa067 PMD 0
[ 1215.153338] Oops: 0002 [#1] SMP
[ 1215.153343] CPU 1
[ 1215.153344] Modules linked in: af_packet rose mkiss ax25 nfsd 
exportfs nfs nfs_acl auth_rpcgss fscache lockd sunrpc netconsole 
configfs bnep bluetooth rfkill snd_hda_codec_idt snd_hda_intel 
snd_hda_codec snd_hwdep snd_pcm snd_page_alloc snd_timer snd 
i82975x_edac soundcore e1000e ppdev parport_pc parport edac_core 
iTCO_wdt iTCO_vendor_support serio_raw i2c_i801 processor coretemp evdev 
ipv6 autofs4 usbhid hid ext4 crc16 jbd2 sd_mod crc_t10dif firewire_ohci 
firewire_core ehci_hcd crc_itu_t uhci_hcd usbcore usb_common nouveau 
button video mxm_wmi wmi i2c_algo_bit drm_kms_helper ttm drm i2c_core 
ahci libahci ata_piix pata_marvell libata scsi_mod [last unloaded: 
microcode]
[ 1215.153395]
[ 1215.153398] Pid: 18637, comm: ifconfig Not tainted 3.4.7 #8 
/D975XBX2
[ 1215.153404] RIP: 0010:[<ffffffffa065e37d>]  [<ffffffffa065e37d>] 
rose_device_event+0x11d/0x160 [rose]
[ 1215.153411] RSP: 0000:ffff880035271ca8  EFLAGS: 00010296
[ 1215.153414] RAX: 0000000000000000 RBX: ffff88003d0c2838 RCX: 
0000000230924000
[ 1215.153417] RDX: 0000000000000002 RSI: 0000000000000001 RDI: 
ffffffffa0665f28
[ 1215.153420] RBP: ffff880035271cb8 R08: 0000000000000002 R09: 
0000000000000000
[ 1215.153422] R10: 0000000000000003 R11: 0000000000000000 R12: 
ffff88003a9e1000
[ 1215.153425] R13: 00000000fffffff1 R14: ffffffffa05b0000 R15: 
0000000000000000
[ 1215.153429] FS:  00007fb7a318f700(0000) GS:ffff88003fa80000(0000) 
knlGS:0000000000000000
[ 1215.153433] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1215.153435] CR2: 000000000000002a CR3: 00000000393fd000 CR4: 
00000000000007e0
[ 1215.153438] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[ 1215.153441] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
[ 1215.153445] Process ifconfig (pid: 18637, threadinfo 
ffff880035270000, task ffff88003f5f5d90)
[ 1215.153448] Stack:
[ 1215.153450]  0000000000000002 ffff88003a9e1000 ffff880035271cf8 
ffffffff8146d86d
[ 1215.153455]  ffff880036040d00 0000000000000002 ffff88003a9e1000 
0000000000000000
[ 1215.153459]  00000000ffffff9d 0000000000000000 ffff880035271d08 
ffffffff8107a2b6
[ 1215.153464] Call Trace:
[ 1215.153470]  [<ffffffff8146d86d>] notifier_call_chain+0x4d/0x70
[ 1215.153476]  [<ffffffff8107a2b6>] raw_notifier_call_chain+0x16/0x20
[ 1215.153483]  [<ffffffff81395136>] call_netdevice_notifiers+0x36/0x60
[ 1215.153487]  [<ffffffff8139b9ea>] __dev_notify_flags+0x6a/0x90
[ 1215.153491]  [<ffffffff8139ba55>] dev_change_flags+0x45/0x70
[ 1215.153496]  [<ffffffff81403aed>] devinet_ioctl+0x61d/0x7b0
[ 1215.153500]  [<ffffffff81403f05>] inet_ioctl+0x75/0x90
[ 1215.153505]  [<ffffffff8137fbd0>] sock_do_ioctl+0x30/0x70
[ 1215.153509]  [<ffffffff8137fc89>] sock_ioctl+0x79/0x2f0
[ 1215.153514]  [<ffffffff811829d8>] do_vfs_ioctl+0x98/0x560
[ 1215.153517]  [<ffffffff81182f31>] sys_ioctl+0x91/0xa0
[ 1215.153522]  [<ffffffff81471b39>] system_call_fastpath+0x16/0x1b
[ 1215.153525] Code: e0 5b 41 5c 31 c0 5d c3 48 8d 7b c8 31 c9 ba 09 00 
00 00 be 65 00 00 00 e8 a1 5c 00 00 48 8b 83 b8 04 00 00 48 c7 c7 28 5f 
66 a0 <66> 83 68 2a 01 48 8b 83 b8 04 00 00 0f b7 70 2a 31 c0 e8 d4 10
[ 1215.153561] RIP  [<ffffffffa065e37d>] rose_device_event+0x11d/0x160 
[rose]
[ 1215.153567]  RSP <ffff880035271ca8>
[ 1215.153569] CR2: 000000000000002a
[ 1215.177577] ---[ end trace d23a7ddff228876c ]---
[ 1215.177589] Kernel panic - not syncing: Fatal exception in interrupt
[ 1215.177662] panic occurred, switching back to text console
[ 1215.177717] Rebooting in 60 seconds..

I inserted some printk into rose_device_event() and commented calls to 
subroutines.
Without calling subroutines, there is no more kernel panic.
Same results when replacing rose_kill_by_device() in net/rose/af_rose.c, 
rose_link_device_down() and rose_rt_device() in
net/rose_route.c by a dummy functions with just a printk inside.

I am glad that I found make parameters that shorten the debugging
cycle :

make modules SUBDIRS=net/rose
make modules_install SUBDIRS=net/rose

Now I have to go further into each subroutines step by step in order to 
find out the falty code !


Bernard


On 03/08/2012 16:32, folkert wrote:
>> You might want to simply try moving unregister_netdevice_notifier a bit
>> earlier in rose_exit and see if that helps.  Otherwise I would recommend
>> instrumenting the code up with some printk so you can understand what
>> part of unregistration is failing.
>
> Or bisect! Give e.g. the oldest 2.6 kernel a try to find a last known
> good and then do a bisect upto a known bad kernel.
>
>
> Folkert van Heusden
>

