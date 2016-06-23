From: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Subject: Re: [PATCH net-next v2 3/4] cgroup: bpf: Add bpf_skb_in_cgroup_proto
Date: Thu, 23 Jun 2016 22:07:27 +0200
Message-ID: <576C417F.6000301@iogearbox.net>
References: <1466630252-3822277-1-git-send-email-kafai@fb.com> <1466630252-3822277-4-git-send-email-kafai@fb.com> <576BB1AE.5080605@iogearbox.net> <20160623165449.GC82305@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, kernel-team-b10kYP2dOMg@public.gmane.org
To: Martin KaFai Lau <kafai-b10kYP2dOMg@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160623165449.GC82305-ik1955jzaFFGY1KPJGhogQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 06/23/2016 06:54 PM, Martin KaFai Lau wrote:
> On Thu, Jun 23, 2016 at 11:53:50AM +0200, Daniel Borkmann wrote:
>>> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
>>> index 668e079..68753e0 100644
>>> --- a/kernel/bpf/verifier.c
>>> +++ b/kernel/bpf/verifier.c
>>> @@ -1062,6 +1062,10 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
>>>   		if (func_id != BPF_FUNC_get_stackid)
>>>   			goto error;
>>>   		break;
>>> +	case BPF_MAP_TYPE_CGROUP_ARRAY:
>>> +		if (func_id != BPF_FUNC_skb_in_cgroup)
>>> +			goto error;
>>> +		break;
>>
>> I think the BPF_MAP_TYPE_CGROUP_ARRAY case should have been fist here in
>> patch 2/4, but with unconditional goto error. And this one only adds the
>> 'func_id != BPF_FUNC_skb_in_cgroup' test.
> I am not sure I understand.  Can you elaborate? I am probably missing
> something here.

If someone backports patch 2/4 as-is, but for some reason not 3/4, then you
could craft a program that calls f.e. bpf_map_update_elem() on a cgroup array
and would thus cause a NULL pointer deref, since verifier doesn't prevent it.
I'm just trying to say that it would probably make sense to add the above 'case
BPF_MAP_TYPE_CGROUP_ARRAY:' with an unconditional 'goto error' in patch 2/4
and extend upon it in patch 3/4 so result looks like here, so that the patches
are fine/complete each as stand-alone.
