From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2008-11-26-17-00 uploaded
Date: Fri, 28 Nov 2008 11:42:57 -0800
Message-ID: <20081128114257.a651b9ee.akpm@linux-foundation.org>
References: <200811270101.mAR114rp016378@imap1.linux-foundation.org>
	<200811282209.FDC95384.tLQJFOFOHFMSOV@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755273AbYK1Tn3@vger.kernel.org>
In-Reply-To: <200811282209.FDC95384.tLQJFOFOHFMSOV@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 Nov 2008 22:09:06 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:

> > The mm-of-the-moment snapshot 2008-11-26-17-00 has been uploaded to
> I got below bug.
> CentOS 5.2 (gcc (GCC) 4.1.2 20071124 (Red Hat 4.1.2-42)) on VMware Workstation 6.5.1.
> 
> [   24.978638] BUG: unable to handle kernel NULL pointer dereference at 00000004
> [   24.980541] IP: [<c056bfb7>] loopback_get_stats+0x26/0x51
> [   24.982191] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
> [   24.982989] last sysfs file: /sys/class/firmware/microcode/loading
> [   24.982989] Modules linked in: rfkill input_polldev sbs sbshc battery floppy serio_raw rtc_cmos rtc_core rtc_lib ac button pcnet32 mii i2c_piix4 i2c_core mptspi mptscsih mptbase scsi_transport_spi ext3 jbd mbcache [last unloaded: microcode]
> [   24.982989] 
> [   24.982989] Pid: 2213, comm: sadc Not tainted (2.6.28-rc6-mm1 #1) VMware Virtual Platform
> [   24.982989] EIP: 0060:[<c056bfb7>] EFLAGS: 00010297 CPU: 0
> [   24.982989] EIP is at loopback_get_stats+0x26/0x51
> [   24.982989] EAX: 00000000 EBX: debf8848 ECX: 00000001 EDX: 00000001
> [   24.982989] ESI: 00000000 EDI: 00000000 EBP: de7b9efc ESP: de7b9eec
> [   24.982989]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> [   24.982989] Process sadc (pid: 2213, ti=de7b9000 task=de5fc0b0 task.ti=de7b9000)
> [   24.982989] Stack:
> [   24.982989]  21415ecf debf8800 ddc2fda0 ddc2fda0 de7b9f04 c05a71be de7b9f14 c05a7613
> [   24.982989]  c062db2c debf8800 de7b9f54 c049d8be 00001000 b7d58000 ddf08310 ddc2fdc0
> [   24.982989]  00000000 00000000 000000c8 00000001 00000000 00000000 00000000 fffffffb
> [   24.982989] Call Trace:
> [   24.982989]  [<c05a71be>] ? dev_get_stats+0x19/0x1b
> [   24.982989]  [<c05a7613>] ? dev_seq_show+0x21/0x80
> [   24.982989]  [<c049d8be>] ? seq_read+0x1f2/0x2d8
> [   24.982989]  [<c049d6cc>] ? seq_read+0x0/0x2d8
> [   24.982989]  [<c04b5b0f>] ? proc_reg_read+0x60/0x74
> [   24.982989]  [<c04b5aaf>] ? proc_reg_read+0x0/0x74
> [   24.982989]  [<c048a6da>] ? vfs_read+0x6d/0x91
> [   24.982989]  [<c048a930>] ? sys_read+0x3b/0x5d
> [   24.982989]  [<c04032d1>] ? sysenter_do_call+0x12/0x31
> [   24.982989] Code: 66 c0 56 c0 c3 55 83 c9 ff 89 e5 57 31 ff 56 31 f6 53 83 ec 04 8d 58 48 8b 80 20 03 00 00 89 45 f0 eb 0d 8b 45 f0 f7 d0 8b 04 88 <03> 78 04 03 30 89 c8 ba 50 96 79 c0 e8 72 a3 f7 ff 83 f8 1f 89 
> [   24.982989] EIP: [<c056bfb7>] loopback_get_stats+0x26/0x51 SS:ESP 0068:de7b9eec
> [   25.029067] ---[ end trace a599d5330cca1e8d ]---

At a guess I'd say that local variable `stats' in loopback_get_stats()
is null.

That code was recently changed in linux-next:

commit c02373bf2759dd210dc8c72c9c9b4a8f1c279cac
Author: Stephen Hemminger <shemminger@vyatta.com>
Date:   Wed Nov 19 21:46:18 2008 -0800

    netdev: convert loopback to net_device_ops
    
    First device to convert over is the loopback device.
    
    Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

but it's a bit hard to see how that change could cause the crash which
you observed.
