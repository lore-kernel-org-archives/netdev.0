From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: tun netns BUG()
Date: Fri, 05 Jun 2009 10:17:43 +0100
Message-ID: <1244193463.3751.129.camel@macbook.infradead.org>
References: <1244142352.3751.14.camel@macbook.infradead.org>
	 <m17hzr7a0o.fsf@fess.ebiederm.org>
	 <1244191328.3751.111.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-ozNLi3yKydYXDmbP7D/Q"
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37168 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753199AbZFEJRo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 05:17:44 -0400
In-Reply-To: <1244191328.3751.111.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ozNLi3yKydYXDmbP7D/Q
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 2009-06-05 at 09:42 +0100, David Woodhouse wrote:
> I've been experimenting with a standalone test case but haven't yet
> managed to reproduce it.

This works, although it's probably still more complex than it needs to
be...

# ./tuncrash 
/sbin/ip link set tun0 netns 3495
Open tun1 in child
/sbin/ip link set tun1 netns 3492
del tun1
child bye

[  748.322433] ------------[ cut here ]------------
[  748.327046] kernel BUG at net/core/dev.c:4241!
[  748.331519] invalid opcode: 0000 [#1] SMP 
[  748.335767] last sysfs file: /sys/devices/virtual/net/tun1/flags
[  748.341804] CPU 4 
[  748.343900] Modules linked in: tun firewire_ohci firewire_core crc_itu_t [last unloaded: scsi_wait_scan]
[  748.353654] Pid: 3495, comm: tuncrash Not tainted 2.6.30-rc8 #71         
[  748.360466] RIP: 0010:[<ffffffff813b485c>]  [<ffffffff813b485c>] rollback_registered+0x75/0xfe
[  748.369149] RSP: 0018:ffff8801510f7d88  EFLAGS: 00010202
[  748.374486] RAX: 0000000000000002 RBX: ffff88015cea3000 RCX: ffff88015f195602
[  748.381644] RDX: 0000000000000000 RSI: 0000000000000292 RDI: ffff88015cea3000
[  748.388808] RBP: ffff8801510f7d98 R08: ffff8801510f6000 R09: 0000000000de76a8
[  748.395978] R10: ffff88015cea3600 R11: 0000000005f5e100 R12: ffff88015cea3600
[  748.403128] R13: ffff88015c80ce00 R14: 0000000000000008 R15: ffff88015d0d06f0
[  748.410296] FS:  00007f85d1d036f0(0000) GS:ffff88002d064000(0000) knlGS:0000000000000000
[  748.418411] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  748.424186] CR2: 0000000000401cc8 CR3: 0000000156c9d000 CR4: 00000000000006a0
[  748.431345] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  748.438508] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  748.445672] Process tuncrash (pid: 3495, threadinfo ffff8801510f6000, task ffff880155b347e0)
[  748.454133] Stack:
[  748.456177]  ffff88015cea3600 ffff88015cea3000 ffff8801510f7db8 ffffffff813b491f
[  748.463566]  ffff8801510f7db8 ffff8801520d38a0 ffff8801510f7dd8 ffffffffa002446a
[  748.471221]  ffff8801550bb440 ffff88015d0d06f0 ffff8801510f7e28 ffffffff810addf7
[  748.479107] Call Trace:
[  748.481587]  [<ffffffff813b491f>] unregister_netdevice+0x3a/0x69
[  748.487640]  [<ffffffffa002446a>] tun_chr_close+0x3d/0x79 [tun]
[  748.493670]  [<ffffffff810addf7>] __fput+0xe3/0x18a
[  748.498644]  [<ffffffff810adeb3>] fput+0x15/0x17
[  748.503377]  [<ffffffff810ab257>] filp_close+0x63/0x6d
[  748.508585]  [<ffffffff810372e1>] put_files_struct+0x67/0xbe
[  748.514286]  [<ffffffff81037373>] exit_files+0x3b/0x40
[  748.519462]  [<ffffffff81038c1c>] do_exit+0x1e6/0x715
[  748.524590]  [<ffffffff8104b7ab>] ? up_read+0x9/0xb
[  748.529507]  [<ffffffff814bbd81>] ? do_page_fault+0x1d4/0x1fa
[  748.535330]  [<ffffffff810391bb>] do_group_exit+0x70/0x9d
[  748.540797]  [<ffffffff810391fa>] sys_exit_group+0x12/0x16
[  748.546361]  [<ffffffff8100b9eb>] system_call_fastpath+0x16/0x1b
[  748.552441] Code: 89 de 48 89 da 48 c7 c7 88 33 6d 81 e8 46 32 10 00 be 8d 10 00 00 48 c7 c7 13 2e 6d 81 e8 5b 11 c8 ff e9 88 00 00 00 ff c8 74 04 <0f> 0b eb fe 48 89 df e8 f6 fe ff ff 48 89 df e8 ee cf ff ff c7 
[  748.574374] RIP  [<ffffffff813b485c>] rollback_registered+0x75/0xfe
[  748.580722]  RSP <ffff8801510f7d88>
[  748.584638] ---[ end trace 4f761942078445d9 ]---
[  748.589250] Fixing recursive fault but reboot is needed!


-- 
dwmw2

--=-ozNLi3yKydYXDmbP7D/Q
Content-Disposition: inline; filename="tuncrash.c"
Content-Type: text/x-csrc; name="tuncrash.c"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <net/if.h>
#include <sys/ioctl.h>
#include <linux/if_tun.h>
#include <linux/sched.h>

int main(int argc, char **argv)
{
	struct ifreq ifr;
	pid_t pid, ppid = getpid();
	int fd;

	fd = open("/dev/net/tun", O_RDWR);
	if (fd < 0) {
		perror("open tun");
		exit(1);
	}

	memset(&ifr, 0, sizeof(ifr));

	ifr.ifr_flags = (IFF_TUN | IFF_NO_PI);
	if (ioctl(fd, TUNSETIFF, &ifr) < 0) {
		perror("TUNSETIFF");
		exit(1);
	}

	pid = fork();
	if (pid < 0) {
		perror("fork");
		exit(1);
	}
	if (!pid) {
		char *cmd;
		close(fd);
		if (unshare(CLONE_NEWNET) < 0) {
			perror("unshare");
			exit(1);
		}
		/* Wait for the tun device to be given to us... */
		sleep(2);
		
		fd = open("/dev/net/tun", O_RDWR);
		if (fd < 0) {
			perror("open tun");
			exit(1);
		}
		memset(&ifr, 0, sizeof(ifr));

		ifr.ifr_flags = (IFF_TUN | IFF_NO_PI);
		if (ioctl(fd, TUNSETIFF, &ifr) < 0) {
			perror("TUNSETIFF");
			exit(1);
		}
		printf("Open %s in child\n", ifr.ifr_name);

		if (asprintf(&cmd, "/sbin/ip link set %s netns %d",
			     ifr.ifr_name, ppid) < 0) {
			perror("asprintf");
			exit(1);
		}
		printf("%s\n", cmd);
		if (system(cmd)) {
			perror("give tun to parent");
			exit(1);
		}
		sleep(1);
		printf("child bye\n");
		exit(0);
	} else {
		/* Wait for the unshare() */
		char *cmd;

		if (asprintf(&cmd, "/sbin/ip link set %s netns %d",
			     ifr.ifr_name, pid) < 0) {
			perror("asprintf");
			exit(1);
		}
		sleep(1);
		printf("%s\n", cmd);
		if (system(cmd)) {
			perror("give tun to child");
			exit(1);
		}
		free(cmd);
		sleep(1);

		/* Yeah, too lazy to pass the real name back */
		printf("del tun1\n");
		sleep(1);
		system("/sbin/ip link del tun1");
		close(fd);
	}
	return 0;
}

--=-ozNLi3yKydYXDmbP7D/Q--

