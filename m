From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net-next PATCH v2 1/5] introduce IFE action
Date: Wed, 24 Feb 2016 09:39:38 -0800
Message-ID: <CAM_iQpUT-tKBpxDCHyiiTaUXwZOXVa6_4sRFovx2ArNuJCOwCQ@mail.gmail.com>
References: <1456231760-2513-1-git-send-email-jhs@emojatatu.com>
	<1456231760-2513-2-git-send-email-jhs@emojatatu.com>
	<CAM_iQpXb4=PP9=oNWH1vNHb81OGg7ivUtPaD8KfdQqVNYMKgoA@mail.gmail.com>
	<56CDAB97.1060505@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	john fastabend <john.fastabend@gmail.com>, dj@verizon.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f181.google.com ([209.85.161.181]:36094 "EHLO
	mail-yw0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758489AbcBXRjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 12:39:39 -0500
Received: by mail-yw0-f181.google.com with SMTP id e63so21114016ywc.3
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 09:39:38 -0800 (PST)
In-Reply-To: <56CDAB97.1060505@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 24, 2016 at 5:09 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 16-02-23 04:44 PM, Cong Wang wrote:
>>
>> On Tue, Feb 23, 2016 at 4:49 AM, Jamal Hadi Salim <jhs@mojatatu.com>
>> wrote:
>
>
>>> +#define MODULE_ALIAS_IFE_META(metan)   MODULE_ALIAS("ifemeta"
>>> __stringify_1(metan))
>>> +
>>> +int get_meta_u32(struct sk_buff *skb, struct tcf_meta_info *mi);
>>> +int get_meta_u16(struct sk_buff *skb, struct tcf_meta_info *mi);
>>> +int tlv_meta_encode(void *skbdata, u16 attrtype, u16 dlen, const void
>>> *dval);
>>> +int alloc_meta_u32(struct tcf_meta_info *mi, void *metaval);
>>> +int alloc_meta_u16(struct tcf_meta_info *mi, void *metaval);
>>> +int check_meta_u32(u32 metaval, struct tcf_meta_info *mi);
>>> +int encode_meta_u32(u32 metaval, void *skbdata, struct tcf_meta_info
>>> *mi);
>>> +int validate_meta_u32(void *val, int len);
>>> +int validate_meta_u16(void *val, int len);
>>> +void release_meta_gen(struct tcf_meta_info *mi);
>>> +int register_ife_op(struct tcf_meta_ops *mops);
>>> +int unregister_ife_op(struct tcf_meta_ops *mops);
>>
>>
>>
>> These are exported to other modules, please add some prefix to protect
>> them.
>>
>
> suggestion? I thought they seemed unique enough.
>

I would pick "ife_", for example, ife_get_meta_u32() ...


>
>>> + * copyright   Jamal Hadi Salim (2015)
>>
>>
>>
>> 2016? ;)
>>
>
> Yes. This code has been around since then. Actually earlier than that
> running. But i formatted it for kernel inclusion in about first week
> of January. Dave asked me to wait for the ethertype to get it in.
> The IETF still hasnt come through a year later and so i re-submitted
> with no default ethertype. I think 2015 is deserving here, no?
> I hope i dont spend another year discussing on the list ;-> /me runs

I thought it should be always the time when you submit the code, but
you are the author you have the right to make it whatever you want... ;)

[...]

>>> +       if ((parm->flags & IFE_ENCODE) && (parm->flags & IFE_DECODE)) {
>>> +               pr_info("Ambigous: Cant have both encode and decode\n");
>>> +               return -EINVAL;
>>> +       }
>>
>>
>>
>> Is it possible to fold them into one bit?
>
>
> As in the check you mean?
>

I meant to suggest to make IFE_ENCODE and IFE_DECODE share
one bit.
