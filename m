From: Jiri Slaby <jslaby@suse.cz>
Subject: tun: Failed to create tun sysfs files [was: mmotm 2011-03-02-16-52
 uploaded]
Date: Fri, 04 Mar 2011 09:56:09 +0100
Message-ID: <4D70A929.4010900@suse.cz>
References: <201103030127.p231ReNl012841@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org,
	Jiri Slaby <jirislaby@gmail.com>,
	ML netdev <netdev@vger.kernel.org>, maxk@qualcomm.com,
	vtun@office.satix.net
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201103030127.p231ReNl012841@imap1.linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/03/2011 01:52 AM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2011-03-02-16-52 has been uploaded to

Hi, I'm seeing this with tun (also with earlier versions):
WARNING: at fs/sysfs/dir.c:455 sysfs_add_one+0xb8/0xe0()
Hardware name: To Be Filled By O.E.M.
sysfs: cannot create duplicate filename '/devices/virtual/net/tun0/group'
Modules linked in: microcode dvb_usb_af9015 tda18271 af9013 dvb_usb dvb_core
Pid: 3840, comm: openvpn Not tainted 2.6.38-rc4-mm1_64+ #1390
Call Trace:
 [<ffffffff8106d61a>] ? warn_slowpath_common+0x7a/0xb0
 [<ffffffff8106d6f1>] ? warn_slowpath_fmt+0x41/0x50
 [<ffffffff81176638>] ? sysfs_add_one+0xb8/0xe0
 [<ffffffff8117570d>] ? sysfs_add_file_mode+0x5d/0xa0
 [<ffffffff8117575c>] ? sysfs_add_file+0xc/0x10
 [<ffffffff81175841>] ? sysfs_create_file+0x21/0x40
 [<ffffffff813609d4>] ? device_create_file+0x14/0x20
 [<ffffffff813e0256>] ? tun_set_iff+0x3f6/0x4a0
 [<ffffffff813e05fe>] ? __tun_chr_ioctl+0x12e/0x5d0
 [<ffffffff8126c5c2>] ? __strncpy_from_user+0x22/0x60
 [<ffffffff813e0ade>] ? tun_chr_ioctl+0xe/0x10
 [<ffffffff811274ed>] ? do_vfs_ioctl+0x8d/0x300
 [<ffffffff811277aa>] ? sys_ioctl+0x4a/0x80
 [<ffffffff81030dbb>] ? system_call_fastpath+0x16/0x1b

It's because these devices already contain 'group' in the sysfs dir.

regards,
-- 
js
suse labs
