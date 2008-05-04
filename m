From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: Need help debugging memory corruption
Date: Sun, 4 May 2008 14:52:40 -0500
Message-ID: <20080504145240.67754191@osprey.hogchain.net>
References: <20080503130951.091392ba@osprey.hogchain.net>
	<e2e108260805040802l4b2bb9dfjce898903fe746a1c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Chris Snook" <csnook@redhat.com>
To: "Bart Van Assche" <bart.vanassche@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost03.isp.att.net ([207.115.11.53]:42453 "EHLO
	fmailhost01.isp.att.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754873AbYEDTwn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 15:52:43 -0400
In-Reply-To: <e2e108260805040802l4b2bb9dfjce898903fe746a1c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 4 May 2008 17:02:59 +0200
"Bart Van Assche" <bart.vanassche@gmail.com> wrote:

> Are you familiar with the kernel command-line option slub_debug=3DFZP=
U ?
> If this was not yet enabled, recompiling your kernel with
> CONFIG_SLUB=3Dy and CONFIG_SLUB_DEBUG=3Dy enabled and specifying
> slub_debug=3DFZPU on the kernel command line will probably provide mo=
re
> detailed information about the cause of the memory corruption.

Bart,

Using slub_debug=3DFZPU didn't seem to add more information.
CONFIG_SLUB=3Dy and CONFIG_SLUB_DEBUG=3Dy are (and were previously) set=
=2E

Thanks.

title Fedora (2.6.26-rc1)
        root (hd0,5)
        kernel /vmlinuz-2.6.26-rc1 ro root=3DLABEL=3D/1 console=3DttyS0=
,38400 console=3Dtty0 slub_debug=3DFZPU
        initrd /initrd-2.6.26-rc1.img


=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
BUG kmalloc-2048: Poison overwritten
-----------------------------------------------------------------------=
------

INFO: 0xffff81010004297a-0xffff810100042f71. First byte 0x0 instead of =
0x6b
INFO: Allocated in dev_alloc_skb+0x16/0x2c age=3D5813 cpu=3D0 pid=3D302=
9
INFO: Freed in skb_release_data+0xa8/0xad age=3D201 cpu=3D0 pid=3D0
INFO: Slab 0xffffe20005801600 objects=3D15 used=3D0 fp=3D0xffff81010004=
5b18 flags=3D0x8000000000002082
INFO: Object 0xffff810100042968 @offset=3D10600 fp=3D0xffff8101000418d8

Bytes b4 0xffff810100042958:  aa 91 fd ff 00 00 00 00 5a 5a 5a 5a 5a 5a=
 5a 5a =EF=BF=BD.=EF=BF=BD=EF=BF=BD....ZZZZZZZZ
  Object 0xffff810100042968:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xffff810100042978:  6b 6b 00 17 31 4e 9d 41 00 0f db bc af 14=
 08 00 kk..1N.A..=DB=BC=EF=BF=BD...
  Object 0xffff810100042988:  45 00 00 4e 87 5e 00 00 40 11 6e 82 c0 a8=
 01 fe E..N.^..@.n.=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=
=EF=BF=BD.=EF=BF=BD
  Object 0xffff810100042998:  c0 a8 01 70 00 89 00 89 00 3a 3b 67 00 09=
 00 00 =EF=BF=BD=EF=BF=BD.p.....:;g....
  Object 0xffff8101000429a8:  00 01 00 00 00 00 00 00 20 43 4b 41 41 41=
 41 41 .........CKAAAAA
  Object 0xffff8101000429b8:  41 41 41 41 41 41 41 41 41 41 41 41 41 41=
 41 41 AAAAAAAAAAAAAAAA
  Object 0xffff8101000429c8:  41 41 41 41 41 41 41 41 41 00 00 21 00 01=
 f0 53 AAAAAAAAA..!..
  Object 0xffff8101000429d8:  56 17 df 3e 3b 9f b7 1f 2d 29 f0 68 cf 4d=
 61 97 V.=EF=BF=BD>;.=EF=BF=BD.-)=EF=BF=BDh=EF=BF=BDMa.
 Redzone 0xffff810100043168:  bb bb bb bb bb bb bb bb                  =
       =EF=BF=BD=F0=B0=BB=BB=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=
=EF=BF=BD       =20
 Padding 0xffff8101000431a8:  5a 5a 5a 5a 5a 5a 5a 5a                  =
       ZZZZZZZZ       =20
Pid: 3030, comm: ifconfig Not tainted 2.6.26-rc1 #3

Call Trace:
 [<ffffffff8108cf62>] print_trailer+0x123/0x12c
 [<ffffffff8108d00f>] check_bytes_and_report+0xa4/0xcb
 [<ffffffff8108d33e>] check_object+0xca/0x212
 [<ffffffff8108d6cd>] __free_slab+0x85/0xfd
 [<ffffffff811e5dd3>] ? skb_release_data+0xa8/0xad
 [<ffffffff8108d77d>] discard_slab+0x38/0x3a
 [<ffffffff8108e172>] __slab_free+0xdb/0x2ac
 [<ffffffff8108e47a>] kfree+0xbc/0xcb
 [<ffffffff811e5dd3>] ? skb_release_data+0xa8/0xad
 [<ffffffff811e5dd3>] skb_release_data+0xa8/0xad
 [<ffffffff811e6494>] skb_release_all+0xc9/0xce
 [<ffffffff811e5c2e>] __kfree_skb+0x11/0x78
 [<ffffffff811e5cbc>] kfree_skb+0x27/0x29
 [<ffffffffa00cc3aa>] :atl1:atl1_clean_rx_ring+0x7e/0xe2
 [<ffffffffa00cc4d7>] :atl1:atl1_down+0xc9/0xce
 [<ffffffffa00cedcd>] :atl1:atl1_close+0x18/0x27
 [<ffffffff811ebe2d>] dev_close+0x57/0x72
 [<ffffffff811ebb31>] dev_change_flags+0xa8/0x164
 [<ffffffff8122f44c>] devinet_ioctl+0x26a/0x5f6
 [<ffffffff8122fc79>] inet_ioctl+0x92/0xaa
 [<ffffffff811df6d4>] sock_ioctl+0x1da/0x202
 [<ffffffff8109f252>] vfs_ioctl+0x2a/0x77
 [<ffffffff8109f501>] do_vfs_ioctl+0x262/0x27f
 [<ffffffff8109f575>] sys_ioctl+0x57/0x7a
 [<ffffffff8100bff7>] tracesys+0xd5/0xda

=46IX kmalloc-2048: Restoring 0xffff81010004297a-0xffff810100042f71=3D0=
x6b
