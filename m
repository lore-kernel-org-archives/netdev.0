From: Andrew Morton <akpm@linux-foundation.org>
Subject: Fw: [Bugme-new] [Bug 7952] New: slattach only works every other
 time
Date: Tue, 6 Feb 2007 13:57:54 -0800
Message-ID: <20070206135754.0a0415b9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	mfuzzey@mailclub.net,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:52656 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965465AbXBFV6Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 16:58:24 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Tue, 6 Feb 2007 13:01:55 -0800
From: bugme-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 7952] New: slattach only works every other time


http://bugzilla.kernel.org/show_bug.cgi?id=7952

           Summary: slattach only works every other time
    Kernel Version: 2.6.18
            Status: NEW
          Severity: normal
             Owner: acme@conectiva.com.br
         Submitter: mfuzzey@mailclub.net


Most recent kernel where this bug did *NOT* occur:2.6.16
Distribution:Debian Etch
Hardware Environment: x86 with serial port (including qemu)
Software Environment: slattach
Problem Description:

First time slattach is run to set up a SLIP line all is ok.
If slattach process is then killed and restarted it fails with message:
SLIP_set_disc(1): File exists
Problem still occurs in 2.6.20rc6 kernel

dmesg shows:
object_add failed for sl0 with -EEXIST, don't try to register things 
with the same name in the same directory.
 [<c01b7b54>] kobject_add+0x147/0x16d
 [<c0211209>] class_device_add+0x9d/0x3b3
 [<c022829d>] register_netdevice+0x21a/0x2d0
 [<c8903213>] slip_open+0x3a1/0x4e2 [slip]
 [<c01fc709>] tty_ioctl+0x922/0xbac
 [<c0117778>] default_wake_function+0x0/0xc
 [<c01fd4bd>] n_tty_open+0x0/0x88
 [<c01fd498>] n_tty_close+0x0/0x25
 [<c01fd3ae>] n_tty_flush_buffer+0x0/0x3b
 [<c01fd2ab>] n_tty_chars_in_buffer+0x0/0x5b
 [<c01fe5eb>] read_chan+0x0/0x551
 [<c01fd545>] write_chan+0x0/0x294
 [<c01fef41>] n_tty_ioctl+0x0/0x40d
 [<c01fd082>] n_tty_set_termios+0x0/0x1cc
 [<c01fe4d2>] normal_poll+0x0/0x119
 [<c01fd7d9>] n_tty_receive_buf+0x0/0xcf9
 [<c01fd24e>] n_tty_write_wakeup+0x0/0x27
 [<c88b2474>] parport_pc_interrupt+0x1a/0x42 [parport_pc]
 [<c013fb83>] handle_IRQ_event+0x23/0x49
 [<c013fc5c>] __do_IRQ+0xb3/0xe8
 [<c013fc80>] __do_IRQ+0xd7/0xe8
 [<c0130170>] hrtimer_run_queues+0xcf/0x157
 [<c016937b>] do_ioctl+0x47/0x5d
 [<c01695db>] vfs_ioctl+0x24a/0x25c
 [<c0121c58>] tasklet_action+0x55/0xaf
 [<c0169635>] sys_ioctl+0x48/0x5f
 [<c0102c11>] sysenter_past_esp+0x56/0x79


Steps to reproduce:
(requires a serial port but nothing needs to be attached to it):
# slattach -L -vd -p slip -s 115200 /dev/ttyS0
slattach: tty_open: looking for lock
slattach: tty_open: trying to open /dev/ttyS0
slattach: tty_open: /dev/ttyS0 (fd=3) slattach: tty_set_speed: 115200
slattach: tty_set_databits: 8
slattach: tty_set_stopbits: 1
slattach: tty_set_parity: N
slip started on /dev/ttyS0 interface sl0

Above is OK, now kill process with CTRL-C

slattach: tty_set_speed: 0
# slattach -L -vd -p slip -s 115200 /dev/ttyS0
slattach: tty_open: looking for lock
slattach: tty_open: trying to open /dev/ttyS0
slattach: tty_open: /dev/ttyS0 (fd=3) slattach: tty_set_speed: 115200
slattach: tty_set_databits: 8
slattach: tty_set_stopbits: 1
slattach: tty_set_parity: N
SLIP_set_disc(1): File exists

# dmesg
Gives trace shown above

I believe this is called by this changeset :
http://www2.kernel.org/git/?p=linux/kernel/git/stable/linux-2.6.17.y.git;a=commit;h=b17a7c179dd3ce7d04373fddf660eda21efc9db9

Regards,

Martin

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
