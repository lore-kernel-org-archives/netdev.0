From: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Subject: Re: [PATCH 9/9] netfilter: implement xt_cgroup cgroup2 path match
Date: Mon, 23 Nov 2015 14:51:39 +0100
Message-ID: <565319EB.2090909@iogearbox.net>
References: <1448122441-9335-1-git-send-email-tj@kernel.org> <1448122441-9335-10-git-send-email-tj@kernel.org> <20151121165605.GC25336@breakpoint.cc> <20151121170425.GD3428@htj.duckdns.org> <20151121185419.GD25336@breakpoint.cc> <565317F0.2030502@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org, daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org,
	nhorman-2XuSBdqkA4SvXiR4WA35Jg@public.gmane.org, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-team-b10kYP2dOMg@public.gmane.org, ninasc-b10kYP2dOMg@public.gmane.org,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Jan Engelhardt <jengelh-9+2X+4sQBs8@public.gmane.org>
To: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <565317F0.2030502-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/23/2015 02:43 PM, Daniel Borkmann wrote:
> On 11/21/2015 07:54 PM, Florian Westphal wrote:
>> Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
>>> On Sat, Nov 21, 2015 at 05:56:06PM +0100, Florian Westphal wrote:
>>>>> +struct xt_cgroup_info_v1 {
>>>>> +    __u8        has_path;
>>>>> +    __u8        has_classid;
>>>>> +    __u8        invert_path;
>>>>> +    __u8        invert_classid;
>>>>> +    char        path[PATH_MAX];
>>>>> +    __u32        classid;
>>>>> +
>>>>> +    /* kernel internal data */
>>>>> +    void        *priv __attribute__((aligned(8)));
>>>>> +};
>>>>
>>>> Ahem.  Am I reading this right? This struct is > 4k in size?
>>>> If so -- Ugh.  Does sizeof(path) really have to be PATH_MAX?
>>>
>>> Hmmm... yeap but would this be an acutual problem?
>>
>> Since rule blob can be allocated via vmalloc i guess "no", its not
>> really a problem unless someone needs realy insane amount of such rules.
>>
>> I don't have any better suggestion, so I guess its necessary evil.
>>
>> The only other question I have is wheter PATH_MAX might be a possible
>> ABI breaker in future.  It would have to be guaranteed that this is the
>> same size forever, else you'd get strange errors on rule insertion if
>> the sizes of the kernel and userspace version differs.
>
> Haven't looked deeply into kernfs, but if it's possible to get the object
> from the struct file eventually, you could let iptables frontend open that
> path and just pass the fd down. Would be sizeof(int) vs PATH_MAX then, i.e.
> when you have a large number of rules to load.

( ... but with the downside that things like save/restore wouldn't work. )
