From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: hso. hso_serial_close oops.
Date: Fri, 10 Oct 2014 10:22:19 -0400
Message-ID: <5437EB9B.8080105@hurleysoftware.com>
References: <5437E6E7.7070107@t2data.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: christian.melki@t2data.com, Jan Dumon <j.dumon@option.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout32.mail01.mtsvc.net ([216.70.64.70]:57693 "EHLO
	n23.mail01.mtsvc.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752077AbaJJOWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 10:22:24 -0400
In-Reply-To: <5437E6E7.7070107@t2data.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ +Jan Dumon, netdev ]

Forwarding oops report to maintainer.

On 10/10/2014 10:02 AM, Christian Melki wrote:
> I'm using a ppc 8347 with a normal 3.16.1 kernel.
> The software opens the driver tty in question and then sets it as stdin, stdout for chat-program and pppd.
> When I yank the modem while running, the software detects this and tries to close the open socket with a kernel crash as a result.
> 
> Unable to handle kernel paging request for unknown fault
> Faulting instruction address: 0xc03a4420
> Oops: Kernel access of bad area, sig: 11 [#1]
> PREEMPT ASP8347E
> Modules linked in:
> CPU: 0 PID: 1536 Comm: pppd Not tainted 3.16.1 #1
> task: c31272e0 ti: c39e8000 task.ti: c39e8000
> NIP: c03a4420 LR: c020752c CTR: c02074e0
> REGS: c39e9d40 TRAP: 0600   Not tainted  (3.16.1)
> MSR: 00009032 <EE,ME,IR,DR,RI>  CR: 24004224  XER: 20000000
> DAR: 0000004d DSISR: 00000000
> GPR00: 00000000 c39e9df0 c31272e0 0000004d c3235460 00000000 c39c1934 00000000
> GPR08: 00000000 00000000 c39c1964 c39c1800 24004228 10047610 10040000 1003f6ec
> GPR16: 1003f6b4 1003f618 1003f6b0 1003f6bc 1003f700 1003f7b4 c39e9edc 1003f6c8
> GPR24: 1003f6dc c03bd1a8 00000004 c03bd2b4 00000000 c3235460 00000000 c38cca00
> NIP [c03a4420] mutex_lock+0x0/0x1c
> LR [c020752c] hso_serial_close+0x4c/0x11c
> Call Trace:
> [c39e9df0] [c3235460] 0xc3235460 (unreliable)
> [c39e9e00] [c0188944] tty_release+0x134/0x560
> [c39e9e90] [c00a1968] __fput+0x94/0x214
> [c39e9eb0] [c0032854] task_work_run+0xcc/0xf4
> [c39e9ed0] [c0019108] do_exit+0x208/0x874
> [c39e9f20] [c00198c0] do_group_exit+0x44/0xd8
> [c39e9f30] [c0019968] __wake_up_parent+0x0/0x34
> [c39e9f40] [c000e60c] ret_from_syscall+0x0/0x38
> --- Exception: c01 at 0xfebd4cc
>     LR = 0xff79a98
> Instruction dump:
> 409e0014 801f003c 70090004 41820008 4bffe6ad 80010034 bb410018 38210030
> 7c0803a6 4e800020 4bffe695 4bffffc4 <7c001828> 3000ffff 7c00192d 40a2fff4
> ---[ end trace bfebaf22f6f5795a ]---
> 
> Fixing recursive fault but reboot is needed!
> 
> I have simulated the same error with a simple userland program without using pppd.
> 
> 
> #include <sys/types.h>
> #include <sys/stat.h>
> #include <fcntl.h>
> #include <unistd.h>
> #include <stdlib.h>
> 
> int
> main(int argc, char *argv[]) {
>     int fd;
>     fd = open(argv[1], O_RDWR);
>     sleep(atoi(argv[2]));
>     close(fd);
> 
>     return 0;
> }
> 
> If I yank the modem while the program is sleeping, I get exactly the same kernel error as with pppd.
> I have looked at the hso.c (hso_serial_close) driver but can't figure it out. The structs might not be intact at that time, but those are tty structs.. Im not sure what is going on. I tried to check the integrity of the structs but still get a crash. The tty layer is a mystery to me.
> 
> regards,
> Christian
