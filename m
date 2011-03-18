From: Diddi Oscarsson <diddi@diddi.se>
Subject: VLAN over GRE segfault
Date: Fri, 18 Mar 2011 08:34:17 +0100
Message-ID: <4D830AF9.8040007@diddi.se>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000702090604010305050306"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:43234 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932066Ab1CRHeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 03:34:22 -0400
Received: by bwz15 with SMTP id 15so3121547bwz.19
        for <netdev@vger.kernel.org>; Fri, 18 Mar 2011 00:34:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000702090604010305050306
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit


-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hello!

I was trying to get ethernet over GRE to work when I found an obvious
way NOT to do it.
Basically I created a VLAN interface from the GRE interface (even
though I had my fair doubts it would work) which gave me a nice segfault.
The problem with this is that after the segfault, new network
connections cannot be made (ping, ssh, http, whatever) and a reboot of
the computer is necessary.
I think an error message needs to be added when trying an operation
like this.

My system:
Linux colalapp 2.6.37-2-amd64 #1 SMP Sun Feb 27 10:12:22 UTC 2011
x86_64 GNU/Linux
ip utility, iproute2-ss110107
Debian unstable

Steps to reproduce:
ip tunnel add gre0 mode gre
ip link add link gre0 name vlan1 type vlan id 1
ip link set vlan1 address 00:15:14:13:12:11
ip link set gre0 up
ip link set vlan1 up
<CRASH>
Attached in the mail is an output from dmesg right after the segfault.

Regarding ethernet over gre, I've just found out about gretap which
I'm testing right now.
BR
Diddi
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQEcBAEBAgAGBQJNgwr5AAoJEA4EcRXoFHyYL+4H/iENafoHp780qO2Kjfz1UWkj
XDAijBm+CI7cq+0Bs3VgvtP86ym/Qe5ueJok+dm4nfrboLpg93Z3UssbvF9RbngI
CJllJ+jIMDPJveioSEif8VIiaPT3LVkp2DO2nDOgRMdAFfYANzWQCX44FJTtX11v
R5gtYPLxv0v6iODhBMcYorTeC/x+Z607K7QaoSQhmKqt/ehw1bG2c30zHCUBNKMS
mU216M811ZDr87JQ86hm8ADkQUrCzoi50yAMjX0M0iiOX/yjyLD2VnqWNco0bPJE
CgH+5Bc8+6jNRsofYoi8d5g+g7Q2RpA7Xx1kiJrD2sR6SKr+vjTt/DIsSY+SXNA=
=mWZT
-----END PGP SIGNATURE-----


--------------000702090604010305050306
Content-Type: text/plain;
 name="crash.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="crash.log"

[396626.662104] device gre0 entered promiscuous mode
[396626.662561] skb_under_panic: text:ffffffffa0935af7 len:80 put:24 head:ffff880078b8d000 data:ffff880078b8cff8 tail:0x48 end:0x100 dev:veth0
[396626.662742] ------------[ cut here ]------------
[396626.662790] kernel BUG at /build/buildd-linux-2.6_2.6.37-2-amd64-bITS0h/linux-2.6-2.6.37/debian/build/source_amd64_none/net/core/skbuff.c:146!
[396626.662891] invalid opcode: 0000 [#1] SMP 
[396626.662932] last sysfs file: /sys/devices/pci0000:00/0000:00:1c.1/0000:03:00.0/net/wlan0/statistics/tx_bytes
[396626.663010] CPU 0 
[396626.663029] Modules linked in: tun macvlan dummy 8021q garp stp ip_gre gre veth binfmt_misc fuse loop firewire_sbp2 btusb bluetooth snd_hda_codec_analog snd_hda_intel arc4 ecb snd_hda_codec iwl3945 thinkpad_acpi iwlcore snd_hwdep snd_pcm i915 snd_seq drm_kms_helper snd_timer drm mac80211 snd_seq_device pcmcia snd snd_page_alloc i2c_i801 soundcore cfg80211 yenta_socket i2c_algo_bit tpm_tis pcmcia_rsrc pcmcia_core i2c_core battery tpm ac tpm_bios nvram power_supply serio_raw psmouse video pcspkr output rfkill evdev processor button ext3 jbd mbcache sha256_generic cryptd aes_x86_64 aes_generic cbc dm_crypt dm_mod sd_mod crc_t10dif mmc_block ahci libahci ata_piix uhci_hcd ata_generic libata ehci_hcd scsi_mod firewire_ohci sdhci_pci sdhci usbcore mmc_core e1000e firewire_core thermal crc_it
 u_t thermal_sys nls_base [last unloaded: scsi_wait_scan]
[396626.663977] 
[396626.663995] Pid: 1440, comm: ip Not tainted 2.6.37-2-amd64 #1 LENOVO 766929G/766929G
[396626.664105] RIP: 0010:[<ffffffff81261ef7>]  [<ffffffff81261ef7>] skb_push+0x6f/0x7b
[396626.664177] RSP: 0018:ffff88005cd63498  EFLAGS: 00010296
[396626.664221] RAX: 0000000000000095 RBX: ffff880019387000 RCX: 0000000000060d52
[396626.664279] RDX: 0000000000000000 RSI: 0000000000000046 RDI: 0000000000000246
[396626.664337] RBP: ffff8800780bbbf8 R08: 0000000000000002 R09: 0000000000000005
[396626.664395] R10: 0000000000000000 R11: 0000000000000001 R12: ffff8800193876c0
[396626.664453] R13: 000000000000dd86 R14: ffff8800469bfec0 R15: ffff88005cd635a8
[396626.664512] FS:  00007f18c2b21700(0000) GS:ffff88007d400000(0000) knlGS:0000000000000000
[396626.664576] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[396626.664624] CR2: 00007f18c22cc728 CR3: 000000001955c000 CR4: 00000000000006f0
[396626.664682] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[396626.664740] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[396626.664800] Process ip (pid: 1440, threadinfo ffff88005cd62000, task ffff880078132880)
[396626.664862] Stack:
[396626.664881]  0000000000000048 0000000000000100 ffff8800469bf800 ffff88005cd63518
[396626.664956]  0000000000000286 ffffffffa0935af7 ffff88005cd635a8 ffff88005ce4b7f0
[396626.665031]  ffffffff817f4a38 ffff880046862b00 ffff8800469bf800 0000000000000000
[396626.665106] Call Trace:
[396626.665137]  [<ffffffffa0935af7>] ? ipgre_header+0x2e/0x86 [ip_gre]
[396626.665193]  [<ffffffffa094d7e8>] ? vlan_dev_hard_header+0x121/0x139 [8021q]
[396626.665252]  [<ffffffff81053bcd>] ? mod_timer+0x87/0x8e
[396626.665300]  [<ffffffff812721b6>] ? neigh_connected_output+0x94/0xd3
[396626.665355]  [<ffffffff812e829c>] ? ndisc_send_skb+0x144/0x22d
[396626.665405]  [<ffffffff812e97ab>] ? ndisc_send_rs+0x8f/0x9a
[396626.665455]  [<ffffffff812dc422>] ? addrconf_dad_completed+0x71/0xb5
[396626.665508]  [<ffffffff812deaff>] ? addrconf_add_linklocal+0x6e/0x7d
[396626.665561]  [<ffffffff812e00c3>] ? addrconf_notify+0x59e/0x78e
[396626.665612]  [<ffffffff8128e16d>] ? rt_cache_flush+0x1a/0x51
[396626.665662]  [<ffffffff81321f16>] ? notifier_call_chain+0x2e/0x5b
[396626.665714]  [<ffffffff8126b157>] ? __dev_notify_flags+0x34/0x59
[396626.665764]  [<ffffffff8126b1b6>] ? dev_change_flags+0x3a/0x42
[396626.665815]  [<ffffffffa094c625>] ? vlan_device_event+0x42a/0x4ba [8021q]
[396626.665872]  [<ffffffff8128e16d>] ? rt_cache_flush+0x1a/0x51
[396626.668139]  [<ffffffff81321f16>] ? notifier_call_chain+0x2e/0x5b
[396626.670352]  [<ffffffff8126b157>] ? __dev_notify_flags+0x34/0x59
[396626.672524]  [<ffffffff8126b1b6>] ? dev_change_flags+0x3a/0x42
[396626.674682]  [<ffffffff81276ef9>] ? do_setlink+0x26f/0x5ce
[396626.676834]  [<ffffffff81276053>] ? rtnl_fill_ifinfo+0x88e/0x957
[396626.678911]  [<ffffffff8127761c>] ? rtnl_newlink+0x2b3/0x4cb
[396626.680934]  [<ffffffff812773fb>] ? rtnl_newlink+0x92/0x4cb
[396626.682897]  [<ffffffff812651e3>] ? __skb_recv_datagram+0x100/0x23d
[396626.684808]  [<ffffffff8128a3a6>] ? netlink_sendmsg+0x17e/0x294
[396626.686653]  [<ffffffff81276799>] ? rtnetlink_rcv_msg+0x0/0x1ea
[396626.688456]  [<ffffffff812899e1>] ? netlink_rcv_skb+0x34/0x7d
[396626.690221]  [<ffffffff81276790>] ? rtnetlink_rcv+0x1f/0x28
[396626.691893]  [<ffffffff812897cc>] ? netlink_unicast+0xe7/0x14f
[396626.693558]  [<ffffffff8128a49c>] ? netlink_sendmsg+0x274/0x294
[396626.695196]  [<ffffffff8125a876>] ? sock_sendmsg+0x83/0x9b
[396626.696792]  [<ffffffff810d0eef>] ? __do_fault+0x3bc/0x3f3
[396626.698382]  [<ffffffff812640cc>] ? copy_from_user+0x18/0x30
[396626.699924]  [<ffffffff81264410>] ? verify_iovec+0x46/0x98
[396626.701579]  [<ffffffff8125b009>] ? sys_sendmsg+0x22c/0x2b4
[396626.703154]  [<ffffffff8128a13b>] ? netlink_insert+0xfd/0x123
[396626.704721]  [<ffffffff81321eb0>] ? do_page_fault+0x324/0x35c
[396626.706236]  [<ffffffff810d591c>] ? do_brk+0x2ca/0x326
[396626.707710]  [<ffffffff8125ab56>] ? sys_recvmsg+0x4a/0x58
[396626.709198]  [<ffffffff81009a12>] ? system_call_fastpath+0x16/0x1b
[396626.710652] Code: 8b 57 68 48 89 44 24 10 8b 87 d0 00 00 00 48 89 44 24 08 8b bf cc 00 00 00 31 c0 48 89 3c 24 48 c7 c7 4a 32 4f 81 e8 9f af 0b 00 <0f> 0b eb fe 4c 89 c8 48 83 c4 28 c3 48 83 ec 28 83 7f 6c 00 89 
[396626.714396] RIP  [<ffffffff81261ef7>] skb_push+0x6f/0x7b
[396626.715992]  RSP <ffff88005cd63498>
[396626.724990] ---[ end trace 36ec1d4936ba3c26 ]---


--------------000702090604010305050306
Content-Type: application/octet-stream;
 name="crash.log.sig"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="crash.log.sig"

iQEcBAABAgAGBQJNgwr5AAoJEA4EcRXoFHyYV08IALdP4L+ItNA++/hLpoJBAKZmzEcswMNP
2JcUrtkreQw0Dx2s/PuXvx24tXeyxnW02ZTlHmswnaMSJ/ZL+ybA+4YP4MKW8wC7Gzbu7mxI
17swmOChcKqT/Y/EVAHS0r5qXCzd/VYYP7quPkhAoK6fsvKh3SWHlVYPgtmv3j8Mvfot1g0b
EF0I6XjwB6LV6wCbW+BmNTkZaxFpQrcVDq48jmSPoTDawMoaYJaSZSqNrj7sQ9Rx7UHPAsHE
AgZ4h9iXEG1FYwdD4wYL8J7o61Fy43KpZaOXpVbQnGmN6v1/eMCd7uRTQOUu0NlAmmd36Q1r
m+jR5EKPk2qlc8pMzLhFcfo=
--------------000702090604010305050306--
