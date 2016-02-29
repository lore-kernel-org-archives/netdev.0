From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v3 1/3] net: sched: consolidate offload decision
 in cls_u32
Date: Mon, 29 Feb 2016 15:40:26 -0800
Message-ID: <56D4D6EA.50608@gmail.com>
References: <20160226154858.5338.90569.stgit@john-Precision-Tower-5810>	<20160226155349.5338.74615.stgit@john-Precision-Tower-5810>	<CAM_iQpVPa7Twx35K-VjR6X0DJ9wQuSeTrfFSZe8HWU_yJVj2UA@mail.gmail.com>	<56D124F1.3070300@gmail.com>	<CAM_iQpWMKWWqtrmPEQZGfDwMZoRq4dvCmirc850tmhbRGT1LNQ@mail.gmail.com>	<56D490B5.5060302@gmail.com>	<20160229185812.GA2121@nanopsycho.orion> <CAM_iQpVP-HbhN=p0xq=wBvjYFG8rF9RCJr=r1-gznMh0ZfGCqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, simon.horman@netronome.com,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34597 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832AbcB2Xkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 18:40:40 -0500
Received: by mail-pa0-f41.google.com with SMTP id fy10so100096524pac.1
        for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 15:40:40 -0800 (PST)
In-Reply-To: <CAM_iQpVP-HbhN=p0xq=wBvjYFG8rF9RCJr=r1-gznMh0ZfGCqA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-29 01:25 PM, Cong Wang wrote:
> On Mon, Feb 29, 2016 at 10:58 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Mon, Feb 29, 2016 at 07:40:53PM CET, john.fastabend@gmail.com wrote:
>>> On 16-02-27 08:28 PM, Cong Wang wrote:
>>>> On Fri, Feb 26, 2016 at 8:24 PM, John Fastabend
>>>> <john.fastabend@gmail.com> wrote:
>>>>> On 16-02-26 09:39 AM, Cong Wang wrote:
>>>>>> On Fri, Feb 26, 2016 at 7:53 AM, John Fastabend
>>>>>> <john.fastabend@gmail.com> wrote:
>>>>>>> diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
>>>>>>> index 2121df5..e64d20b 100644
>>>>>>> --- a/include/net/pkt_cls.h
>>>>>>> +++ b/include/net/pkt_cls.h
>>>>>>> @@ -392,4 +392,9 @@ struct tc_cls_u32_offload {
>>>>>>>         };
>>>>>>>  };
>>>>>>>
>>>>>>> +static inline bool tc_should_offload(struct net_device *dev)
>>>>>>> +{
>>>>>>> +       return dev->netdev_ops->ndo_setup_tc;
>>>>>>> +}
>>>>>>> +
>>>>>>
>>>>>> These should be protected by CONFIG_NET_CLS_U32, no?
>>>>>>
>>>>>
>>>>> Its not necessary it is a completely general function and I only
>>>>> lifted it out of cls_u32 so that the cls_flower classifier could
>>>>> also use it.
>>>>>
>>>>> I don't see the need off-hand to have it wrapped in an ORd ifdef
>>>>> statement where its (CONFIG_NET_CLS_U32 | CONFIG_NET_CLS_X ...).
>>>>> Any particular reason you were thnking it should be wrapped in ifdefs?
>>>>>
>>>>
>>>> Not a big deal.
>>>>
>>>> I just feel these don't need to compile when I have CONFIG_NET_CLS_U32=n.
>>>>
>>>> Thanks.
>>>>
>>>
>>> Well because this is 'static inline' gcc should just remove it
>>> if it is not used. Assuming non-ancient gcc and normal compile
>>> flags, e.g. you are not including -fkeep-inline-functions or
>>> something.
>>>
>>> So just to keep it readable I would prefer to just leave it
>>> as is.
>>
>> Definitelly. cls_flower will use it in very near future. Making it
>> dependent on CONFIG_NET_CLS_U32 makes 0 sense to me.
> 
> Oh, why then do you have u32 in the struct name tc_cls_u32_offload?
> 
> (Note that in the above I said "these" not "this", so I never only refer
> to tc_should_offload)
> 

hmm yeah that likely wont be needed by flower although it could be used.
I still think its best to leave this as is there doesn't seem to be a
very strong precedent to wrap any of the other structs/fields/etc in
pkt_cls.h into their respective ifdef/endif blocks. And I think it
starts to get a bit much if we do. I'm trusting gcc here can do the
right thing when these are included but never used.

Thanks,
John
