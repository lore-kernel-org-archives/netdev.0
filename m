From: Marcel Holtmann <marcel@holtmann.org>
Subject: Oops when stopping IPsec connection
Date: Thu, 23 Sep 2004 23:40:55 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095975655.5976.13.camel@pegasus>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Network Development Mailing List <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

when I stop my IPsec connection I see the following oops with the latest
kernel from the BK tree. Has anyone an idea what is wrong?

Unable to handle kernel paging request at virtual address 00a02d0d
 printing eip:
c0266185
*pde = 00000000
Oops: 0000 [#1]
Modules linked in: ide_cd cdrom rfcomm hidp l2cap ds irda crc_ccitt af_packet bi
nfmt_misc deflate zlib_deflate zlib_inflate twofish serpent aes_i586 blowfish de
s sha256 sha1 md5 crypto_null xfrm_user ipcomp esp4 ah4 af_key yenta_socket ehci
_hcd h2usb hci_usb ohci_hcd 8250_pci 8250 serial_core snd_intel8x0 snd_ac97_code
c snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd_page_alloc snd_mpu401_uart snd
_rawmidi snd soundcore usbhid uhci_hcd intel_agp agpgart evdev nls_iso8859_1 nls
_cp437 vfat fat nls_base eth1394 st bluetooth usbcore pcmcia_core w83781d i2c_se
nsor i2c_i801 i2c_core ohci1394 ieee1394 sd_mod aic7xxx scsi_mod e100 mii unix
CPU:    0
EIP:    0060:[<c0266185>]    Not tainted VLI
EFLAGS: 00010286   (2.6.9-rc2) 
EIP is at fib_nh_match+0x58/0x61
eax: dfff4ac0   ebx: de84b148   ecx: dfff4ac0   edx: df27e430
esi: 00a02c95   edi: df27e410   ebp: de84b140   esp: c0c93c34
ds: 007b   es: 007b   ss: 0068
Process ip (pid: 24496, threadinfo=c0c92000 task=d3054020)
Stack: 00000000 df27e410 c02680dd df27e410 df27e400 dfff4ac0 00a02c95 0007801e 
       00000000 00000000 dd50b6c0 00000013 00a02c95 df27e410 df27e400 dfff4ac0 
       df27e400 c02657d1 dffcda80 df27e410 dfff4ac0 df27e400 ddf130b8 ddf13080 
Call Trace:
 [<c02680dd>] fn_hash_delete+0x231/0x243
 [<c02657d1>] inet_rtm_delroute+0x66/0x7a
 [<c022f08b>] rtnetlink_rcv+0x2dc/0x394
 [<c0235b50>] netlink_data_ready+0x61/0x69
 [<c0235249>] netlink_sendskb+0x32/0x54
 [<c02357e3>] netlink_sendmsg+0x1f9/0x2fc
 [<c021f85f>] sock_sendmsg+0x11a/0x11c
 [<c0161739>] __mark_inode_dirty+0x19d/0x1a2
 [<c021f85f>] sock_sendmsg+0x11a/0x11c
 [<c01af4d4>] copy_from_user+0x42/0x6e
 [<c01126f8>] autoremove_wake_function+0x0/0x57
 [<c02212f7>] sys_sendmsg+0x189/0x1e6
 [<c01387d5>] handle_mm_fault+0xd2/0x138
 [<c010ff57>] do_page_fault+0x192/0x590
 [<c013af65>] do_brk+0x1f8/0x25c
 [<c01af4d4>] copy_from_user+0x42/0x6e
 [<c0221781>] sys_socketcall+0x236/0x254
 [<c0139377>] sys_brk+0xd8/0xfd
 [<c010fdc5>] do_page_fault+0x0/0x590
 [<c010478d>] error_code+0x2d/0x38
 [<c0103d63>] syscall_call+0x7/0xb
Code: c4 08 c3 8b 51 0c 85 d2 75 21 8b 79 10 85 ff 74 16 8b 41 10 85 c0 74 0f 8d
 7e 7c b9 04 00 00 00 fc 89 c6 f3 a6 75 cc 31 c0 eb cd <8b> 46 78 39 02 75 c1 eb
 dd 55 57 56 53 81 ec b4 00 00 00 8b b4 
 
Regards

Marcel
