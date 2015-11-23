From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 9/9] netfilter: implement xt_cgroup cgroup2 path match
Date: Mon, 23 Nov 2015 14:43:12 +0100
Message-ID: <565317F0.2030502@iogearbox.net>
References: <1448122441-9335-1-git-send-email-tj@kernel.org> <1448122441-9335-10-git-send-email-tj@kernel.org> <20151121165605.GC25336@breakpoint.cc> <20151121170425.GD3428@htj.duckdns.org> <20151121185419.GD25336@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, daniel.wagner@bmw-carit.de,
	nhorman@tuxdriver.co, lizefan@huawei.com, hannes@cmpxchg.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, ninasc@fb.com,
	Neil Horman <nhorman@tuxdriver.com>,
	Jan Engelhardt <jengelh@inai.de>
To: Florian Westphal <fw@strlen.de>, Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151121185419.GD25336@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/21/2015 07:54 PM, Florian Westphal wrote:
> Tejun Heo <tj@kernel.org> wrote:
>> On Sat, Nov 21, 2015 at 05:56:06PM +0100, Florian Westphal wrote:
>>>> +struct xt_cgroup_info_v1 {
>>>> +	__u8		has_path;
>>>> +	__u8		has_classid;
>>>> +	__u8		invert_path;
>>>> +	__u8		invert_classid;
>>>> +	char		path[PATH_MAX];
>>>> +	__u32		classid;
>>>> +
>>>> +	/* kernel internal data */
>>>> +	void		*priv __attribute__((aligned(8)));
>>>> +};
>>>
>>> Ahem.  Am I reading this right? This struct is > 4k in size?
>>> If so -- Ugh.  Does sizeof(path) really have to be PATH_MAX?
>>
>> Hmmm... yeap but would this be an acutual problem?
>
> Since rule blob can be allocated via vmalloc i guess "no", its not
> really a problem unless someone needs realy insane amount of such rules.
>
> I don't have any better suggestion, so I guess its necessary evil.
>
> The only other question I have is wheter PATH_MAX might be a possible
> ABI breaker in future.  It would have to be guaranteed that this is the
> same size forever, else you'd get strange errors on rule insertion if
> the sizes of the kernel and userspace version differs.

Haven't looked deeply into kernfs, but if it's possible to get the object
from the struct file eventually, you could let iptables frontend open that
path and just pass the fd down. Would be sizeof(int) vs PATH_MAX then, i.e.
when you have a large number of rules to load.
