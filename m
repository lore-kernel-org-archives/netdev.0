From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net-next PATCH v3 1/3] net: sched: consolidate offload decision
 in cls_u32
Date: Sat, 27 Feb 2016 20:28:46 -0800
Message-ID: <CAM_iQpWMKWWqtrmPEQZGfDwMZoRq4dvCmirc850tmhbRGT1LNQ@mail.gmail.com>
References: <20160226154858.5338.90569.stgit@john-Precision-Tower-5810>
	<20160226155349.5338.74615.stgit@john-Precision-Tower-5810>
	<CAM_iQpVPa7Twx35K-VjR6X0DJ9wQuSeTrfFSZe8HWU_yJVj2UA@mail.gmail.com>
	<56D124F1.3070300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Daniel Borkmann <daniel@iogearbox.net>,
	simon.horman@netronome.com,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f174.google.com ([209.85.161.174]:35498 "EHLO
	mail-yw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992738AbcB1E2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2016 23:28:47 -0500
Received: by mail-yw0-f174.google.com with SMTP id g127so98375072ywf.2
        for <netdev@vger.kernel.org>; Sat, 27 Feb 2016 20:28:47 -0800 (PST)
In-Reply-To: <56D124F1.3070300@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 26, 2016 at 8:24 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
> On 16-02-26 09:39 AM, Cong Wang wrote:
>> On Fri, Feb 26, 2016 at 7:53 AM, John Fastabend
>> <john.fastabend@gmail.com> wrote:
>>> diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
>>> index 2121df5..e64d20b 100644
>>> --- a/include/net/pkt_cls.h
>>> +++ b/include/net/pkt_cls.h
>>> @@ -392,4 +392,9 @@ struct tc_cls_u32_offload {
>>>         };
>>>  };
>>>
>>> +static inline bool tc_should_offload(struct net_device *dev)
>>> +{
>>> +       return dev->netdev_ops->ndo_setup_tc;
>>> +}
>>> +
>>
>> These should be protected by CONFIG_NET_CLS_U32, no?
>>
>
> Its not necessary it is a completely general function and I only
> lifted it out of cls_u32 so that the cls_flower classifier could
> also use it.
>
> I don't see the need off-hand to have it wrapped in an ORd ifdef
> statement where its (CONFIG_NET_CLS_U32 | CONFIG_NET_CLS_X ...).
> Any particular reason you were thnking it should be wrapped in ifdefs?
>

Not a big deal.

I just feel these don't need to compile when I have CONFIG_NET_CLS_U32=n.

Thanks.
