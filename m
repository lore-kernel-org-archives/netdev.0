From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] bpf: make tracing helpers gpl only
Date: Sun, 25 Oct 2015 11:17:58 -0700
Message-ID: <562D1CD6.6020307@plumgrid.com>
References: <1445637499-11146-1-git-send-email-ast@kernel.org>
 <20151025091411.GE24337@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Kaixu Xia <xiakaixu@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151025091411.GE24337@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/25/15 2:14 AM, Ingo Molnar wrote:
> so I don't know the netfilter ones, but in particular the tracing ones I'm sure
> should be gpl-only. Do we really, really want proprietary modules mucking with
> such internals??

of course, not. Therefore bpf_probe_read() was gpl_only from very
beginning. Same goes to bpf_trace_printk() and bpf_ktime_get_ns().
and after this patch the only remaining non-gpl tracing helpers will be
bpf_get_current_pid_tgid()/uid_gid()/comm()
and imo it's fine.

On the networking side the helpers are non-gpl, since all of them are
generic. They don't mess with kernel, but examine/modify the packet.
Just like cBPF can read the packet data, get_processor_id, get_random,
eBPF can do the same plus write into the packet, compute checksum,
redirect, push/pop vlan.

When we introduce eBPF for seccomp, I would argue that helpers on that
side should be non-gpl as well, otherwise people will try to add
features to cBPF instead of moving to eBPF.
