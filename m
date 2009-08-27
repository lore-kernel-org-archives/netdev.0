From: Bill Fink <billfink@mindspring.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Thu, 27 Aug 2009 13:32:42 -0400
Message-ID: <20090827133242.d02acece.billfink@mindspring.com>
References: <20090807205442.32918186.billfink@mindspring.com>
	<20090808015612.GA17710@localhost.localdomain>
	<20090814164412.be5daa74.billfink@mindspring.com>
	<20090814232543.GA28599@hmsreliant.think-freely.org>
	<20090820035044.9b70fca6.billfink@mindspring.com>
	<20090820201919.GA20750@localhost.localdomain>
	<20090821001421.214a560b.billfink@mindspring.com>
	<20090821152341.GA2998@localhost.localdomain>
	<20090826031057.375303c9.billfink@mindspring.com>
	<20090826110013.GA10816@hmsreliant.think-freely.org>
	<20090826180811.GB10816@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Network Developers <netdev@vger.kernel.org>, brice@myri.com,
	gallatin@myri.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-kukur.atl.sa.earthlink.net ([209.86.89.65]:39851 "EHLO
	elasmtp-kukur.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751185AbZH0Rco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2009 13:32:44 -0400
In-Reply-To: <20090826180811.GB10816@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 Aug 2009, Neil Horman wrote:

> On Wed, Aug 26, 2009 at 03:10:57AM -0400, Bill Fink wrote:
> > On Fri, 21 Aug 2009, Neil Horman wrote:
> > 
> > > On Fri, Aug 21, 2009 at 12:14:21AM -0400, Bill Fink wrote:
> > > > On Thu, 20 Aug 2009, Neil Horman wrote:
> > > > 
> > > > > On Thu, Aug 20, 2009 at 03:50:44AM -0400, Bill Fink wrote:
> > > > > 
> > > > > > When I tried an actual nuttcp performance test, even when rate limiting
> > > > > > to just 1 Mbps, I immediately got a kernel oops.  I tried to get a
> > > > > > crashdump via kexec/kdump, but the kexec kernel, instead of just
> > > > > > generating a crashdump, fully booted the new kernel, which was
> > > > > > extremely sluggish until I rebooted it through a BIOS re-init,
> > > > > > and never produced a crashdump.  I tried this several times and
> > > > > > an immediate kernel oops was always the result (with either a TCP
> > > > > > or UDP test).  A ping test of 1000 9000-byte packets with an interval
> > > > > > of 0.001 seconds (which is 72 Mbps for 1 second) on the other hand
> > > > > > worked just fine.
> > > > > 
> > > > > The sluggishness is expected, since the kdump kernel operates out of such
> > > > > limited memory.  don't know why you booted to a full system rather than did a
> > > > > crash recovery.  Don't suppose you got a backtrace did you?
> > > > 
> > > > There was a backtrace on the screen but I didn't have a chance to
> > > > record it.  BTW did anyone ever think to print the backtrace in
> > > > reverse (first to some reserved memory and then output to the display)
> > > > so the more interesting parts wouldn't have scrolled off the top of
> > > > the screen?
> > > > 
> > > The real solution is to use a console to which the output doesn't scroll off the
> > > screen.  Normally people use a serial console they can log, or a RAC card that
> > > they can record. Even on a regular vga monitor in text mode, you can set up the
> > > vt iirc to allow for scrolling.
> > 
> > None of our Asus P6T6 systems have serial consoles.  I don't know of
> > any RAC cards for them either, nor are there spare PCI slots available
> > in many cases.  I wouldn't think the Shift-PageUp trick would work
> > with a crashed kernel, but I admit I didn't try it.  I haven't checked
> > out netconsole yet either, but I'm not sure it would help either in a
> > case like this that was a network related kernel crash.
> > 
> Any USB ports that you can attach a serial dongle to?  That would work as well,
> or, as previously mentioned, netconsole also does the trick.

I didn't know you could use a USB serial port as a serial console.
And after wasting several hours yesterday trying to get a USB serial
console to work without any success, I'm giving up on that idea.
Also since it requires building the required usb modules into the
kernel, it wouldn't be practical, since I'd have to rebuild the
kernel quite frequently given the frequency of Fedora kernel updates.
I still need to check into netconsole.

> > In any case, a simple kernel command line that would provide a reversed
> > backtrace would be a simple thing to facilitate Linux users providing
> > useful info to Linux kernel developers in helping to debug kernel
> > problems.  The most useful info would still be on the screen, so it
> > could be transcribed or a photo image of the screen could be taken.
> > 
> I understand what your saying, I'm just saying there are currently several
> options for you that have already solved this problem in differnt ways.

I would have been with you if the USB serial console idea had panned out.
But I've just about eliminated all the proposed alternatives as viable,
except for netconsole which I haven't investigated yet.  Sometimes the
additional low tech option of a reversed traceroute would be quite
convenient and not require lots of extra effort from the user.  BTW
ISTR that someone else suggested the same idea a while back, but it
didn't get any traction then either (can't find it in the archives
though from a quick search).

> > Fortunately, in this specific case, the SuperMicro X8DAH+-F system
> > does have a serial console, and after a fair amount of effort I was
> > able to get it to work as desired, and was able to finally capture
> > a backtrace of the kernel oops.  BTW I believe the reason the
> > kexec/kdump didn't work was probably because it couldn't find
> > a /proc/vmcore file, although I don't know why that would be,
> > and the Fedora 10 /etc/init.d/kdump script will then just boot
> > up normally if it fails to find the /proc/vmcore file (or it's
> > zero size).
> > 
> I take care of kdump for fedora and RHEL.  If you file a bug on this, I'd be
> happy to look into it further.

It's odd.  kexec/kdump works fine with the 2.6.29.6-217.2.3.fc11.x86_64
kernel from Fedora 11 (running on the Fedora 10 system).  I will try
again with the kernel-2.6.31-0.174.rc7.git2.fc12.src.rpm from Fedora 12,
in case it has some secret sauce in one of the Fedora patches to make
the Fedora /etc/init.d/kdump script happy.  kexec/kdump is my preferred
method of dealing with kernel oopses if I can get it to work.

Also, to get the /sbin/mkdumprd to work right, I had to make the
following change to it:

--- .orig/mkdumprd	2009-04-07 10:03:58.000000000 -0400
+++ .mod/mkdumprd	2009-08-19 19:04:38.000000000 -0400
@@ -384,7 +384,7 @@
             vg_list="$vg_list $vg"
             for device in `vgdisplay -v $vg 2>/dev/null | sed -n 's/PV Name//p'`; do
                 IS_UUID=`echo $device | grep UUID`
-                IS_LABEL=`echo $device | grep UUID`
+                IS_LABEL=`echo $device | grep LABEL`
                 if [ -n "$IS_UUID" -o -n "$IS_LABEL" ]
                 then
                     devname=`findfs $device`
@@ -398,7 +398,7 @@
         esac
     else
         IS_UUID=`echo $1 | grep UUID`
-        IS_LABEL=`echo $1 | grep UUID`
+        IS_LABEL=`echo $1 | grep LABEL`
         if [ -n "$IS_UUID" -o -n "$IS_LABEL" ]
         then
             devname=`findfs $1`

Without the patch to the /sbin/mkdumprd script, it couldn't find
my root filesystem on LABEL=root.

> > The following shows a simple ping test usage of the skb_sources
> > tracing feature:
> > 
> > [root@xeontest1 tracing]# numactl --membind=1 taskset -c 4 ping -c 5 -s 1472 192.168.1.10
> > PING 192.168.1.10 (192.168.1.10) 1472(1500) bytes of data.
> > 1480 bytes from 192.168.1.10: icmp_seq=1 ttl=64 time=0.139 ms
> > 1480 bytes from 192.168.1.10: icmp_seq=2 ttl=64 time=0.182 ms
> > 1480 bytes from 192.168.1.10: icmp_seq=3 ttl=64 time=0.178 ms
> > 1480 bytes from 192.168.1.10: icmp_seq=4 ttl=64 time=0.188 ms
> > 1480 bytes from 192.168.1.10: icmp_seq=5 ttl=64 time=0.178 ms
> > 
> > --- 192.168.1.10 ping statistics ---
> > 5 packets transmitted, 5 received, 0% packet loss, time 3999ms
> > rtt min/avg/max/mdev = 0.139/0.173/0.188/0.017 ms
> > 
> > [root@xeontest1 tracing]# cat trace
> > # tracer: skb_sources
> > #
> > #       PID     ANID    CNID    IFC     RXQ     CCPU    LEN
> > #        |       |       |       |       |       |       |
> >         4217    1       1       eth2    0       4       1500
> >         4217    1       1       eth2    0       4       1500
> >         4217    1       1       eth2    0       4       1500
> >         4217    1       1       eth2    0       4       1500
> >         4217    1       1       eth2    0       4       1500
> > 
> > All is as was expected.
> > 
> > But if I try an actual nuttcp performance test (even rate limited
> > to 1 Mbps), I get the following kernel oops:
> > 
> thank you, I think I see the problem, I'll have a patch for you in just a bit

Thanks for the patch.  I'll address the results of using the patch
in a separate e-mail.

						-Bill



> > [root@xeontest1 tracing]# numactl --membind=1 nuttcp -In2 -Ri1m -xc4/0 192.168.1.10
> > BUG: unable to handle kernel NULL pointer dereference at 0000000000000038
> > IP: [<ffffffff810b01ab>] probe_skb_dequeue+0xf7/0x152
> > PGD 337d12067 PUD 337d11067 PMD 0
> > Oops: 0000 [#1] SMP
> > last sysfs file: /sys/devices/pci0000:80/0000:80:07.0/0000:8b:00.0/0000:8c:04.0e
> > CPU 4
> > Modules linked in: w83627ehf hwmon_vid coretemp hwmon ipv6 dm_multipath uinput ]
> > Pid: 4222, comm: nuttcp Not tainted 2.6.31-rc6-bf #3 X8DAH
> > RIP: 0010:[<ffffffff810b01ab>]  [<ffffffff810b01ab>] probe_skb_dequeue+0xf7/0x12
> > RSP: 0018:ffff8801a5811a88  EFLAGS: 00010213
> > RAX: 0000000000000000 RBX: ffff88033906d154 RCX: 000000000000000d
> > RDX: 000000000000f88c RSI: 000000000000000b RDI: ffff8803383d3044
> > RBP: ffff8801a5811ab8 R08: 0000000000000001 R09: ffff8801ab311a00
> > R10: 0000000000000005 R11: ffffc9000080e2b0 R12: ffff880337c45400
> > R13: ffff88033906d150 R14: 0000000000000014 R15: ffffffff818bb890
> > FS:  00007fa976d326f0(0000) GS:ffffc90000800000(0000) knlGS:0000000000000000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > CR2: 0000000000000038 CR3: 000000033801e000 CR4: 00000000000006e0
> > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > Process nuttcp (pid: 4222, threadinfo ffff8801a5810000, task ffff8801ab2e5d00)
> > Stack:
> >  ffff8801a5811ab8 ffff8801b35d4ab0 0000000000000014 0000000000000000
> > <0> 0000000000000014 0000000000000014 ffff8801a5811b18 ffffffff81366ae8
> > <0> ffff8801a5811ed8 0000001439084000 ffff880337c45400 00000001001416ef
> > Call Trace:
> >  [<ffffffff81366ae8>] skb_copy_datagram_iovec+0x50/0x1f5
> >  [<ffffffff813ac875>] tcp_rcv_established+0x278/0x6db
> >  [<ffffffff813b3ef5>] tcp_v4_do_rcv+0x1b8/0x366
> >  [<ffffffff8135f99e>] ? release_sock+0xab/0xb4
> >  [<ffffffff8136004d>] ? sk_wait_data+0xc8/0xd6
> >  [<ffffffff813a32d6>] tcp_prequeue_process+0x79/0x8f
> >  [<ffffffff813a455d>] tcp_recvmsg+0x4e8/0xaa0
> >  [<ffffffff8135ec90>] sock_common_recvmsg+0x37/0x4c
> >  [<ffffffff8135cb06>] __sock_recvmsg+0x72/0x7f
> >  [<ffffffff8135cbdd>] sock_aio_read+0xca/0xda
> >  [<ffffffff810d9536>] ? vma_merge+0x2a0/0x318
> >  [<ffffffff810f6d4f>] do_sync_read+0xec/0x132
> >  [<ffffffff81067ddc>] ? autoremove_wake_function+0x0/0x3d
> >  [<ffffffff811b646c>] ? security_file_permission+0x16/0x18
> >  [<ffffffff810f785c>] vfs_read+0xc0/0x107
> >  [<ffffffff810f7971>] sys_read+0x4c/0x75
> >  [<ffffffff81011c82>] system_call_fastpath+0x16/0x1b
> > Code: 44 89 73 30 89 43 14 41 0f b7 84 24 ac 00 00 00 89 43 28 65 8b 04 25 98 e
> > RIP  [<ffffffff810b01ab>] probe_skb_dequeue+0xf7/0x152
> >  RSP <ffff8801a5811a88>
> > CR2: 0000000000000038
