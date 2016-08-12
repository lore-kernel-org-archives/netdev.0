From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v4 2/3] bpf: Add bpf_current_task_under_cgroup
 helper
Date: Fri, 12 Aug 2016 09:40:39 +0200
Message-ID: <57AD7D77.4090205@iogearbox.net>
References: <20160812031454.GA2075@ircssh.c.rugged-nimbus-611.internal> <20160812044818.GA39190@ast-mbp.thefacebook.com> <CAMp4zn-0ox8DLO0jNP9Z2+RKqbHmcrRS_dr+L0de_bd=17mp_w@mail.gmail.com> <57AD77B7.5050400@iogearbox.net> <20160812072247.GB31242@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	netdev <netdev@vger.kernel.org>, tj@kernel.org
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58542 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708AbcHLIGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 04:06:01 -0400
In-Reply-To: <20160812072247.GB31242@ircssh.c.rugged-nimbus-611.internal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/12/2016 09:22 AM, Sargun Dhillon wrote:
> On Fri, Aug 12, 2016 at 09:16:07AM +0200, Daniel Borkmann wrote:
>> On 08/12/2016 06:50 AM, Sargun Dhillon wrote:
>>> I realize that in_cgroup is more consistent, but under_cgroup makes
>>> far more sense to me. I think it's more intuitive.
>>>
>>> On Thu, Aug 11, 2016 at 9:48 PM, Alexei Starovoitov
>>> <alexei.starovoitov@gmail.com> wrote:
>>>> On Thu, Aug 11, 2016 at 08:14:56PM -0700, Sargun Dhillon wrote:
>>>>> This adds a bpf helper that's similar to the skb_in_cgroup helper to check
>>>>> whether the probe is currently executing in the context of a specific
>>>>> subset of the cgroupsv2 hierarchy. It does this based on membership test
>>>>> for a cgroup arraymap. It is invalid to call this in an interrupt, and
>>>>> it'll return an error. The helper is primarily to be used in debugging
>>>>> activities for containers, where you may have multiple programs running in
>>>>> a given top-level "container".
>>>>>
>>>>> Signed-off-by: Sargun Dhillon <sargun@sargun.me>
>>>>> Cc: Alexei Starovoitov <ast@kernel.org>
>>>>> Cc: Daniel Borkmann <daniel@iogearbox.net>
>>>>> Cc: Tejun Heo <tj@kernel.org>
>>>>> ---
>>>>> +     /**
>>>>> +      * bpf_current_task_under_cgroup(map, index) - Check cgroup2 membership of current task
>>>>> +      * @map: pointer to bpf_map in BPF_MAP_TYPE_CGROUP_ARRAY type
>>>>> +      * @index: index of the cgroup in the bpf_map
>>>>> +      * Return:
>>>>> +      *   == 0 current failed the cgroup2 descendant test
>>>>> +      *   == 1 current succeeded the cgroup2 descendant test
>>>>> +      *    < 0 error
>>>>> +      */
>>>>> +     BPF_FUNC_current_task_under_cgroup,
>>>> ..
>>>>>        case BPF_MAP_TYPE_CGROUP_ARRAY:
>>>>> -             if (func_id != BPF_FUNC_skb_in_cgroup)
>>>>> +             if (func_id != BPF_FUNC_skb_in_cgroup &&
>>>>> +                 func_id != BPF_FUNC_current_task_under_cgroup)
>>>>>                        goto error;
>>>> ...
>>>>> +     case BPF_FUNC_current_task_under_cgroup:
>>>>>        case BPF_FUNC_skb_in_cgroup:
>>>>
>>>> Tejun,
>>>> do you feel strongly about 'under' ?
>>>> It just looks inconsistent vs existing skb_in_cgroup...
>>>> "in cgroup" - 4k google hits
>>>> "under cgroup" - 2k google hits
>>
>> Alternative could be that we take "BPF_FUNC_current_in_cgroup" as a
>> helper enum to keep consistency with what we have wrt skb helper, but
>> for the cgroup header have the suggested task_under_cgroup_hierarchy()
>> name.
>
> I actually wish we could rename skb_in_cgroup to skb_under_cgroup. If we ever
> introduced a check for absolute membership versus ancestral membership, what
> would we call that?

That option is, by the way, still on the table for -net tree, since 4.8 is not
released yet, so it could still be renamed into BPF_FUNC_skb_under_cgroup.

Then you could make this one here for -net-next as "BPF_FUNC_current_under_cgroup".

Tejun, Alexei?
