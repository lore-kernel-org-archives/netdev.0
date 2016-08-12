From: Sargun Dhillon <sargun@sargun.me>
Subject: Re: [PATCH net-next v4 2/3] bpf: Add bpf_current_task_under_cgroup helper
Date: Thu, 11 Aug 2016 21:50:48 -0700
Message-ID: <CAMp4zn-0ox8DLO0jNP9Z2+RKqbHmcrRS_dr+L0de_bd=17mp_w@mail.gmail.com>
References: <20160812031454.GA2075@ircssh.c.rugged-nimbus-611.internal> <20160812044818.GA39190@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>, tj@kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:34978 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751154AbcHLE4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 00:56:51 -0400
Received: by mail-oi0-f48.google.com with SMTP id 4so21562772oih.2
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 21:56:50 -0700 (PDT)
In-Reply-To: <20160812044818.GA39190@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I realize that in_cgroup is more consistent, but under_cgroup makes
far more sense to me. I think it's more intuitive.

On Thu, Aug 11, 2016 at 9:48 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Thu, Aug 11, 2016 at 08:14:56PM -0700, Sargun Dhillon wrote:
>> This adds a bpf helper that's similar to the skb_in_cgroup helper to check
>> whether the probe is currently executing in the context of a specific
>> subset of the cgroupsv2 hierarchy. It does this based on membership test
>> for a cgroup arraymap. It is invalid to call this in an interrupt, and
>> it'll return an error. The helper is primarily to be used in debugging
>> activities for containers, where you may have multiple programs running in
>> a given top-level "container".
>>
>> Signed-off-by: Sargun Dhillon <sargun@sargun.me>
>> Cc: Alexei Starovoitov <ast@kernel.org>
>> Cc: Daniel Borkmann <daniel@iogearbox.net>
>> Cc: Tejun Heo <tj@kernel.org>
>> ---
>> +     /**
>> +      * bpf_current_task_under_cgroup(map, index) - Check cgroup2 membership of current task
>> +      * @map: pointer to bpf_map in BPF_MAP_TYPE_CGROUP_ARRAY type
>> +      * @index: index of the cgroup in the bpf_map
>> +      * Return:
>> +      *   == 0 current failed the cgroup2 descendant test
>> +      *   == 1 current succeeded the cgroup2 descendant test
>> +      *    < 0 error
>> +      */
>> +     BPF_FUNC_current_task_under_cgroup,
> ..
>>       case BPF_MAP_TYPE_CGROUP_ARRAY:
>> -             if (func_id != BPF_FUNC_skb_in_cgroup)
>> +             if (func_id != BPF_FUNC_skb_in_cgroup &&
>> +                 func_id != BPF_FUNC_current_task_under_cgroup)
>>                       goto error;
> ...
>> +     case BPF_FUNC_current_task_under_cgroup:
>>       case BPF_FUNC_skb_in_cgroup:
>
> Tejun,
> do you feel strongly about 'under' ?
> It just looks inconsistent vs existing skb_in_cgroup...
> "in cgroup" - 4k google hits
> "under cgroup" - 2k google hits
>
