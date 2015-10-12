From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [RFC PATCH 2/2] bpf: Implement
 bpf_perf_event_sample_enable/disable() helpers
Date: Mon, 12 Oct 2015 12:29:34 -0700
Message-ID: <561C0A1E.2080500@plumgrid.com>
References: <1444640563-159175-1-git-send-email-xiakaixu@huawei.com>
 <1444640563-159175-3-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wangnan0@huawei.com, linux-kernel@vger.kernel.org,
	pi3orama@163.com, hekuang@huawei.com, netdev@vger.kernel.org
To: Kaixu Xia <xiakaixu@huawei.com>, davem@davemloft.net,
	acme@kernel.org, mingo@redhat.com, a.p.zijlstra@chello.nl,
	masami.hiramatsu.pt@hitachi.com, jolsa@kernel.org,
	daniel@iogearbox.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444640563-159175-3-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/12/15 2:02 AM, Kaixu Xia wrote:
> +extern const struct bpf_func_proto bpf_perf_event_sample_enable_proto;
> +extern const struct bpf_func_proto bpf_perf_event_sample_disable_proto;

externs are unnecessary. Just make them static.
Also I prefer single helper that takes a flag, so we can extend it
instead of adding func_id for every little operation.

To avoid conflicts if you touch kernel/bpf/* or bpf.h please always
base your patches of net-next.

 > +	atomic_set(&map->perf_sample_disable, 0);

global flag per map is no go.
events are independent and should be treated as such.

Please squash these two patches, since they're part of one logical
feature. Splitting them like this only makes review harder.
