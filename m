From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 2/2] bpf: add event output helper for notifications/sampling/logging
Date: Mon, 18 Apr 2016 09:22:15 +0200
Message-ID: <57148B27.60001@iogearbox.net>
References: <201604180722.wizpe3nL%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, davem@davemloft.net,
	alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
To: kbuild test robot <lkp@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201604180722.wizpe3nL%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/18/2016 01:55 AM, kbuild test robot wrote:
> Hi Daniel,
>
> [auto build test ERROR on net-next/master]
>
> url:    https://github.com/0day-ci/linux/commits/Daniel-Borkmann/bpf-trace-add-BPF_F_CURRENT_CPU-flag-for-bpf_perf_event_output/20160418-063147
> config: m68k-allyesconfig (attached as .config)
> reproduce:
>          wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>          chmod +x ~/bin/make.cross
>          # save the attached .config to linux build tree
>          make.cross ARCH=m68k
>
> All errors (new ones prefixed by >>):
>
>     net/core/filter.c: In function 'bpf_skb_event_output':
>>> net/core/filter.c:1599:2: error: implicit declaration of function 'perf_fetch_caller_regs' [-Werror=implicit-function-declaration]
>       perf_fetch_caller_regs(regs);
>       ^
>     cc1: some warnings being treated as errors
>
> vim +/perf_fetch_caller_regs +1599 net/core/filter.c
>
>    1593	static DEFINE_PER_CPU(struct pt_regs, bpf_pt_regs);
>    1594	
>    1595	static u64 bpf_skb_event_output(u64 r1, u64 r2, u64 flags, u64 r4, u64 size)
>    1596	{
>    1597		struct pt_regs *regs = this_cpu_ptr(&bpf_pt_regs);
>    1598	
>> 1599		perf_fetch_caller_regs(regs);
>    1600	
>    1601		return bpf_perf_event_output((long)regs, r2, flags, r4, size);
>    1602	}

Sorry about that, missed this one. Will fix it up in v2!

Thanks,
Daniel
