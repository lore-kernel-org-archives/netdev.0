From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH perf/core REBASE 2/5] samples/bpf: Switch over to libbpf
Date: Thu, 15 Dec 2016 15:34:40 -0300
Message-ID: <20161215183440.GH6866@kernel.org>
References: <20161214224342.12858-1-joe@ovn.org>
 <20161214224342.12858-3-joe@ovn.org>
 <20161215155022.GE6866@kernel.org>
 <20161215182918.GG6866@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        wangnan0@huawei.com, ast@fb.com, daniel@iogearbox.net,
        Arnaldo Carvalho de Melo <acme@redhat.com>
To: Joe Stringer <joe@ovn.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161215182918.GG6866@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Thu, Dec 15, 2016 at 03:29:18PM -0300, Arnaldo Carvalho de Melo escreveu:
> Em Thu, Dec 15, 2016 at 12:50:22PM -0300, Arnaldo Carvalho de Melo escreveu:
> > Em Wed, Dec 14, 2016 at 02:43:39PM -0800, Joe Stringer escreveu:
> > > Now that libbpf under tools/lib/bpf/* is synced with the version from
> > > samples/bpf, we can get rid most of the libbpf library here.
> > > 
> > > Signed-off-by: Joe Stringer <joe@ovn.org>
> > > Cc: Alexei Starovoitov <ast@fb.com>
> > > Cc: Daniel Borkmann <daniel@iogearbox.net>
> > > Cc: Wang Nan <wangnan0@huawei.com>
> > > Link: http://lkml.kernel.org/r/20161209024620.31660-6-joe@ovn.org
> > > [ Use -I$(srctree)/tools/lib/ to support out of source code tree builds, as noticed by Wang Nan ]
> 
> So, the above comment no longer applied to this adjusted patch from you,
> as you removed one hunk too much, that, after applied, gets samples/bpf/
> to build successfully:
> 
> diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
> index add514e2984a..81b0ef2f7994 100644
> --- a/samples/bpf/Makefile
> +++ b/samples/bpf/Makefile
> @@ -107,6 +107,7 @@ always += lwt_len_hist_kern.o
>  always += xdp_tx_iptunnel_kern.o
>  
>  HOSTCFLAGS += -I$(objtree)/usr/include
> +HOSTCFLAGS += -I$(srctree)/tools/lib/
>  HOSTCFLAGS += -I$(srctree)/tools/testing/selftests/bpf/
>  
>  HOSTCFLAGS_bpf_load.o += -I$(objtree)/usr/include -Wno-unused-variable
> 
> ---------------------
> 
> I added it, continuing...

But then, when I tried to run offwaketime with it, it fails:

[root@jouet bpf]# ./offwaketime  ls
bpf_load_program() err=22
BPF_LDX uses reserved fields
bpf_load_program() err=22
BPF_LDX uses reserved fields
[root@jouet bpf]# 

If I remove this patch and try again, it works:

[root@jouet bpf]# ./offwaketime | head -4
swapper/1;start_secondary;cpu_startup_entry;schedule_preempt_disabled;schedule;__schedule;-;---;; 46
chrome;return_from_SYSCALL_64;do_syscall_64;exit_to_usermode_loop;schedule;__schedule;-;try_to_wake_up;do_futex;sys_futex;do_syscall_64;return_from_SYSCALL_64;;Chrome_ChildIOT 1
firefox;entry_SYSCALL_64_fastpath;sys_poll;do_sys_poll;poll_schedule_timeout;schedule_hrtimeout_range;schedule_hrtimeout_range_clock;schedule;__schedule;-;try_to_wake_up;pollwake;__wake_up_common;__wake_up_sync_key;pipe_write;__vfs_write;vfs_write;sys_write;entry_SYSCALL_64_fastpath;;Timer 3
dockerd-current;entry_SYSCALL_64_fastpath;sys_select;core_sys_select;do_select;poll_schedule_timeout;schedule_hrtimeout_range;schedule_hrtimeout_range_clock;schedule;__schedule;-;try_to_wake_up;futex_wake;do_futex;sys_futex;entry_SYSCALL_64_fastpath;;dockerd-current 2
[root@jouet bpf]# 


So, I'm stopping here so that I can push what I have to Ingo, then I'll get
back to this, hopefully by then you beat me and I have just to retest 8-)

- Arnaldo
