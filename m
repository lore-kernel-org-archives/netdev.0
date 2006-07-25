From: Ian Stirling <tandra@mauve.plus.com>
Subject: Networking lock problem. general protection fault: 0000 [#1]
Date: Tue, 25 Jul 2006 11:38:34 +0100
Message-ID: <44C5F4AA.8020707@mauve.plus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from pih-relay06.plus.net ([212.159.14.133]:30349 "EHLO
	pih-relay06.plus.net") by vger.kernel.org with ESMTP
	id S1751045AbWGYKip (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 06:38:45 -0400
Received: from [81.174.132.210] (helo=[10.0.0.66])
	 by pih-relay06.plus.net with esmtp (Exim) id 1G5KJE-0007Bp-I6
	for netdev@vger.kernel.org; Tue, 25 Jul 2006 11:38:42 +0100
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This happened several seconds after plugging in my wireless network card 
- zd1211 - with the driver from http://sourceforge.net/projects/zd1211/

However.
It was after the module was loaded, when my setup script was being run 
for the device - the relevant portion:

ifconfig $device:1 $alternate
route add $router $device:1
route add default gw router

I'm not sure which route command triggered it.
Hope this is the right place.

general protection fault: 0000 [#1]
PREEMPT
Modules linked in: zd1211 toshiba_acpi aes_i586 rd uhci_hcd 
snd_usb_audio snd_usb_lib snd_hwdep usbhid ehci_hcd ohci_hcd pcmcia 
firmware_class yenta_socket rsrc_nonstatic pcmcia_core eepro100 twofish 
tea sha512 sha256 sha1 serpent michael_mic md5 md4 khazad des deflate 
zlib_deflate zlib_inflate crypto_null cast6 cast5 blowfish arc4 
cryptoloop loop sd_mod usb_storage libusual usbcore snd_es1968 
snd_ac97_codec snd_ac97_bus snd_mpu401_uart snd_rawmidi
CPU:    0
EIP:    0060:[<c02f0864>]    Not tainted VLI
EFLAGS: 00010286   (2.6.17laptop-3110-firstcut #7)
EIP is at fib_find_info+0x4d/0xed
eax: 00000015   ebx: ffffffff   ecx: c6c75aa0   edx: ffffffff
esi: c72421bc   edi: c6c75a9c   ebp: c7242160   esp: c21a9dac
ds: 007b   es: 007b   ss: 0068
Process route (pid: 1856, threadinfo=c21a8000 task=c5a02540)
Stack: 00000001 00000001 ffffffff 00000000 00000000 00000003 00000000 
c21a9ed8
        c72421e0 c7242160 c02f1182 c7242160 00000000 00000000 c7242160 
00000000
        00000000 c21a9ed8 bffada60 c7120ca0 c02f219d c21a9e68 c21a9ed8 
c21a9e58
Call Trace:
  <c02f1182> fib_create_info+0x232/0x3ec  <c02f219d> 
fn_hash_insert+0x94/0x3f7
  <c02effa6> ip_rt_ioctl+0xb5/0x113  <c02aae6e> sock_attach_fd+0x72/0xd2
  <c02eb97d> inet_ioctl+0x34/0x63  <c02ab8dc> sock_ioctl+0x96/0x1b6
  <c0160f11> do_ioctl+0x55/0x68  <c016107e> vfs_ioctl+0x59/0x191
  <c01611e1> sys_ioctl+0x2b/0x46  <c0102d4f> syscall_call+0x7/0xb
Code: 55 24 31 d0 89 54 24 10 8b 55 28 31 d0 89 54 24 0c 89 c2 c1 ea 07 
31 c2 c1 e8 0c 31 c2 a1 c0 1e 42 c0 21 ca 8b 1c 90 85 db 74 20 <8b> 03 
89 44 24 08 8d 74 26 00 8b 53 5c 8b 04 24 89 54 24 04 39
EIP: [<c02f0864>] fib_find_info+0x4d/0xed SS:ESP 0068:c21a9dac
  BUG: route/1856, lock held at task exit time!
  [c03a04a0] {rtnl_mutex}
.. held by:             route: 1856 [c5a02540, 112]
... acquired at:               ip_rt_ioctl+0x5d/0x113
d[2774]: Caught signal 15, un-registering and exiting.

Config is at http://www.mauve.plus.com/config.gz
