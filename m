From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC Patch net-next 2/6] net_sched: introduce tcf_hash_replace()
Date: Tue, 6 Sep 2016 15:34:29 -0700
Message-ID: <CAM_iQpV3hjOtSOBGmCg1dB3uTHp=N6g0SRiXwx2EzugJZbNYFQ@mail.gmail.com>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
 <1472795840-31901-3-git-send-email-xiyou.wangcong@gmail.com> <9b288d0c-507f-d487-aa76-0778fd442f35@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:33601 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933472AbcIFWeu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 18:34:50 -0400
Received: by mail-oi0-f67.google.com with SMTP id w78so11822597oie.0
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 15:34:50 -0700 (PDT)
In-Reply-To: <9b288d0c-507f-d487-aa76-0778fd442f35@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 6, 2016 at 5:52 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 16-09-02 01:57 AM, Cong Wang wrote:
>
>> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> ---
>>  include/net/act_api.h |  2 ++
>>  net/sched/act_api.c   | 20 ++++++++++++++++++++
>>  2 files changed, 22 insertions(+)
>>
>> diff --git a/include/net/act_api.h b/include/net/act_api.h
>> index 82f3c91..a374bab 100644
>> --- a/include/net/act_api.h
>
>
>>
>> +void tcf_hash_replace(struct tc_action_net *tn, struct tc_action **old,
>> +                     struct tc_action *new, int bind)
>> +{
>> +       struct tcf_hashinfo *hinfo = tn->hinfo;
>> +       unsigned int h = tcf_hash(new->tcfa_index, hinfo->hmask);
>> +
>
>
> WWhy do you need to recreate the index?
> Old index was fine since this is just a replacement..

A new index is possible created by tcf_hash_create(), but later
overwritten by tcf_hash_copy(). I know this is a bit ugly, so
feel free to suggest any better API here.


>
> The rest of the patches seem fine - will let Eric comment on the
> mirred.
>
> Note: I am going to still push forward with skbmod action and I think
> so should the new tunnel action code i.e we make them independent.
> I'd like to switch to this when we think it is stable.

You don't have to rebase or change, I will take care of it because they
will probably be merged before this patchset. At least I can hold on
this for a while to let that happen. ;)

Thanks.
