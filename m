From: Andrew Morton <akpm@linux-foundation.org>
Subject: Fw: [BUG] 2.6.20 Oopses in xfrm_audit_log
Date: Mon, 12 Feb 2007 14:21:38 -0800
Message-ID: <20070212142138.32983793.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Charles-Edouard Ruault <ce@ruault.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:44036 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965430AbXBLWVs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Feb 2007 17:21:48 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Mon, 12 Feb 2007 15:16:04 +0100
From: Charles-Edouard Ruault <ce@ruault.com>
To: linux-kernel@vger.kernel.org, linux-net@vger.kernel.org
Subject: [BUG] 2.6.20 Oopses in xfrm_audit_log


Hi All,

i upgraded to vanilla kernel 2.6.20 and while i was using strongswan 
2.8.2 to setup an IPSEC VPN i got the following kernel Ooops.
I had successfully established the same tunnel a few times, but key 
renegotiation caused a problem ( both ends did not renegotiate at the 
same time so the tunnel was frozen ), i decided to kill the tunnel and 
start a new one ( using ipsec auto --down tunnel & ipsec auto --up 
tunnel ), while i was doing so, i got the oops.

BUG: unable to handle kernel NULL pointer dereference at virtual address 
00000188
 printing eip:
c02fb85c
*pde = 00000000
Oops: 0000 [#1]
PREEMPT
Modules linked in: xfrm4_mode_tunnel usblp deflate zlib_deflate twofish 
twofish_common serpent blowfish des cbc ecb blkcipher xcbc sha256 sha1 
crypto_null xfrm4_tunnel tunnel4 ipcomp esp4 ah4 af_key autofs4 asb100 
hwmon_vid hidp rfcomm l2cap bluetooth sunrpc nf_conntrack_netbios_ns 
ipt_LOG xt_limit xt_mark xt_state xt_tcpudp iptable_filter 
ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 xt_MARK 
iptable_mangle ip_tables x_tables binfmt_misc sd_mod ipv6 sg hfsplus 
video button ac lp parport_pc parport floppy nvram usb_storage scsi_mod 
libusual usbhid hid ehci_hcd snd_via82xx snd_ac97_codec ac97_bus 
ohci1394 snd_seq_dummy uhci_hcd ieee1394 snd_seq_oss snd_seq_midi_event 
snd_seq snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd_page_alloc 
snd_mpu401_uart snd_rawmidi snd_seq_device snd via_agp agpgart 
i2c_viapro soundcore eepro100 i2c_core b44 pcspkr mii shpchp usbcore dm_mod
CPU:    0
EIP:    0060:[<c02fb85c>]    Not tainted VLI
EFLAGS: 00010246   (2.6.20 #1)
EIP is at xfrm_audit_log+0x4cc/0x580
eax: ecb71061   ebx: c039d160   ecx: 00000000   edx: 00000021
esi: 000001f4   edi: 00000255   ebp: 00000000   esp: e8cd5a18
ds: 007b   es: 007b   ss: 0068
Process pluto (pid: 27486, ti=e8cd4000 task=d3557070 task.ti=e8cd4000)
Stack: c17d2ea0 c0354bf1 e183f9c0 00000003 c03ac59c e1399800 00000001 
00000003
       f8d0a450 00000000 00000001 00000286 e8cd5a6c c011506b 00000000 
00000286
       f73cb8c0 00000246 c17d2ea0 00000000 00000000 f73cb8c0 f8d03c67 
00000000
Call Trace:
 [<c011506b>] __wake_up+0x4b/0x80
 [<f8d03c67>] pfkey_broadcast+0x137/0x1b0 [af_key]
 [<f8d03e5f>] pfkey_send_policy_notify+0xef/0x1a0 [af_key]
 [<c011d90e>] local_bh_enable+0x2e/0xa0
 [<c0306107>] xfrm_get_policy+0x2b7/0x2f0
 [<c0305e50>] xfrm_get_policy+0x0/0x2f0
 [<c0304702>] xfrm_user_rcv_msg+0x102/0x1b0
 [<c0304600>] xfrm_user_rcv_msg+0x0/0x1b0
 [<c02b3782>] netlink_run_queue+0x82/0x120
 [<c03045e8>] xfrm_netlink_rcv+0x28/0x40
 [<c02b3d42>] netlink_data_ready+0x12/0x50
 [<c02b2931>] netlink_sendskb+0x21/0x40
 [<c02b3c50>] netlink_sendmsg+0x230/0x310
 [<c02993cd>] sock_aio_write+0x11d/0x130
 [<c01d538a>] avc_has_perm+0x5a/0x70
 [<c0163ed5>] do_sync_write+0xd5/0x120
 [<c012c960>] autoremove_wake_function+0x0/0x50
 [<c01648c7>] vfs_write+0x177/0x180
 [<c0164ea1>] sys_write+0x41/0x70
 [<c0102f14>] syscall_call+0x7/0xb
 =======================
Code: 8b 44 24 70 c1 e2 08 c1 e8 08 09 c2 0f b7 c2 89 44 24 08 8b 44 24 
48 89 04 24 e8 10 eb e3 ff e9 bc fc ff ff 8b 8c 24 c0 00 00 00 <8b> 91 
88 01 00 00 0f b7 99 82 00 00 00 85 d2 0f 85 64 fc ff ff
EIP: [<c02fb85c>] xfrm_audit_log+0x4cc/0x580 SS:ESP 0068:e8cd5a18

I'm running a vanilla 2.6.20 kernel on a Fedora Core 5 box on an athlon 
processor:
cat /proc/cpuinfo
processor       : 0
vendor_id       : AuthenticAMD
cpu family      : 6
model           : 8
model name      : AMD Athlon(TM) XP 2400+
stepping        : 1
cpu MHz         : 2000.256
cache size      : 256 KB
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 1
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge 
mca cmov pat pse36 mmx fxsr sse syscall mmxext 3dnowext 3dnow ts
bogomips        : 4003.78
clflush size    : 32

uname -a
Linux machine 2.6.20 #1 PREEMPT Sat Feb 10 13:48:56 CET 2007 i686 athlon 
i386 GNU/Linux

Please CC me in follow ups since i do not subscribe to the list.
Thanks

-- 
Charles-Edouard Ruault
GPG key Id E4D2B80C

-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
