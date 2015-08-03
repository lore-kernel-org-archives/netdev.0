From: Jesse Gross <jesse@nicira.com>
Subject: Re: [ovs-dev] [PATCH v1] netdev: Make 100 percents packets sampled
 when sampling rate is 1.
Date: Mon, 3 Aug 2015 11:30:05 -0700
Message-ID: <CAEP_g=_hG_Bv5B8fkTO0yoOH8we1=Fg43QsmT0+vWUOg0TAqig@mail.gmail.com>
References: <1438585918-20233-1-git-send-email-wenyuz@vmware.com> <CALnjE+qCbqtzMPHKV1M_HRdB+OTRCYsya3XuUeORJHn8E-jEjQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wenyu Zhang <wenyuz@vmware.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:34303 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752711AbbHCSa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 14:30:26 -0400
Received: by labow3 with SMTP id ow3so22764930lab.1
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 11:30:24 -0700 (PDT)
In-Reply-To: <CALnjE+qCbqtzMPHKV1M_HRdB+OTRCYsya3XuUeORJHn8E-jEjQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 3, 2015 at 11:18 AM, Pravin Shelar <pshelar@nicira.com> wrote:
> On Mon, Aug 3, 2015 at 12:11 AM, Wenyu Zhang <wenyuz@vmware.com> wrote:
>> When sampling rate is 1, the sampling probability is UINT32_MAX. The packet
>> should be sampled even the prandom32() generate the number of UINT32_MAX.
>> And none packet need be sampled when the probability is 0.
>>
>> Signed-off-by: Wenyu Zhang <wenyuz@vmware.com>
>> ---
>>  net/openvswitch/actions.c |    4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
>> index cf04c2f..03acb09 100644
>> --- a/net/openvswitch/actions.c
>> +++ b/net/openvswitch/actions.c
>> @@ -669,9 +669,11 @@ static int sample(struct datapath *dp, struct sk_buff *skb,
>>
>>         for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
>>                  a = nla_next(a, &rem)) {
>> +               uint32_t probability;
>>                 switch (nla_type(a)) {
>>                 case OVS_SAMPLE_ATTR_PROBABILITY:
>> -                       if (prandom_u32() >= nla_get_u32(a))
>> +                       probability = nla_get_u32(a);
>> +                       if (!probability || probability > nla_get_u32(a))
>
> This condition does not looks right to calculate sampling probability.

When you send v2, can you also make the subject more narrow
("openvswitch" instead of "netdev") and add the tree that you are
targeting ("[PATCH net]" in this case)?
