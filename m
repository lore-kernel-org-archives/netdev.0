From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: IPv4: sysctl table check failed [was: mmotm 2010-10-07-14-08
 uploaded]
Date: Thu, 7 Oct 2010 15:22:56 -0700
Message-ID: <20101007152256.9c21ef22.akpm@linux-foundation.org>
References: <201010072140.o97Le69i025659@imap1.linux-foundation.org>
	<4CAE4479.6010606@gmail.com>
Reply-To: linux-kernel@vger.kernel.org
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org,
	ML netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <mm-commits-owner@vger.kernel.org>
In-Reply-To: <4CAE4479.6010606@gmail.com>
Sender: mm-commits-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 08 Oct 2010 00:06:49 +0200
Jiri Slaby <jirislaby@gmail.com> wrote:

> On 10/07/2010 11:08 PM, akpm@linux-foundation.org wrote:
> > The mm-of-the-moment snapshot 2010-10-07-14-08 has been uploaded to
> 
> Hi, I got bunch of "sysctl table check failed" below. All seem to be
> related to ipv4:
> 
> sysctl table check failed: /net/ipv4/tcp_mem  No min
> Pid: 1, comm: swapper Not tainted 2.6.36-rc7-mm1_64+ #1285
> Call Trace:
>  [<ffffffff8108d444>] set_fail+0xa4/0xf0
>  [<ffffffff8108d736>] sysctl_check_table+0x2a6/0x310
>  [<ffffffff8108d4eb>] sysctl_check_table+0x5b/0x310
>  [<ffffffff8108d4eb>] sysctl_check_table+0x5b/0x310
>  [<ffffffff81072204>] __register_sysctl_paths+0xf4/0x320
>  [<ffffffff815c1232>] ? printk+0x3c/0x42
>  [<ffffffff8115d3bc>] ? sysfs_add_file+0xc/0x10
>  [<ffffffff818b18bd>] ? sysctl_ipv4_init+0x0/0x87
>  [<ffffffff81072456>] register_sysctl_paths+0x26/0x30
>  [<ffffffff818b18fd>] sysctl_ipv4_init+0x40/0x87
>  [<ffffffff810002df>] do_one_initcall+0x3f/0x170
>  [<ffffffff81884d44>] kernel_init+0x158/0x1e2
>  [<ffffffff8102fb54>] kernel_thread_helper+0x4/0x10
>  [<ffffffff81884bec>] ? kernel_init+0x0/0x1e2
>  [<ffffffff8102fb50>] ? kernel_thread_helper+0x0/0x10

OK, thanks.

Eric D's net-avoid-limits-overflow.patch switched tcp_mem and udp_mem
from proc_dointvec() to proc_doulongvec_minmax().  And
sysctl_check_table() checks `min' and `max' for
proc_doulongvec_minmax() but not for proc_dointvec().

I'm not sure which Eric to blame ;) .min and .max are optional, so
perhaps the check is wrong?

