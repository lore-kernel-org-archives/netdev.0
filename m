From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [LKP] [net] 2ab9fb18c4: kernel BUG at include/linux/skbuff.h:1935!
Date: Tue, 15 Nov 2016 10:30:15 -0800
Message-ID: <CAKgT0UeuZtFsypWtEhuSB+Lx1gN32TP3mPdD5R1x8YNzvAFKkQ@mail.gmail.com>
References: <5828fc09.rTUEnj6qw0eDHzYL%xiaolong.ye@intel.com>
 <1479088020.8455.41.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161114021420.GC31218@yexl-desktop> <20161114031130.yjb4anou24ede4ue@wfg-t540p.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ye Xiaolong <xiaolong.ye@intel.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Willem de Bruijn <willemb@google.com>,
        netdev <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Jojy Varghese <jojvargh@cisco.com>,
        Tom Herbert <tom@herbertland.com>,
        Yibin Yang <yibyang@cisco.com>, LKP <lkp@01.org>,
        David Miller <davem@davemloft.net>
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35571 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932987AbcKOSaS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 13:30:18 -0500
Received: by mail-it0-f68.google.com with SMTP id b123so1842681itb.2
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 10:30:16 -0800 (PST)
In-Reply-To: <20161114031130.yjb4anou24ede4ue@wfg-t540p.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 13, 2016 at 7:11 PM, Fengguang Wu <fengguang.wu@intel.com> wrote:
>>> Hi guys.
>>>
>>> I took a look at the commit again and I do not see how this can happen.
>>>
>>> Are you sure patch was properly applied ?
>>>
>>> In particular, the following extract is obscure for me :
>>>
>>>
>>>> https://github.com/0day-ci/linux
>>>> Eric-Dumazet/net-__skb_flow_dissect-must-cap-its-return-value/20161110-080839
>>>> commit 2ab9fb18c46b91b16a0f0f329336d3be9fc32deb ("net:
>>>> __skb_flow_dissect() must cap its return value")
>>>>
>>
>> Hi,
>>
>> The above two lines means 0day repo setup a new branch
>>
>> "Eric-Dumazet/net-__skb_flow_dissect-must-cap-its-return-value/20161110-080839"
>> which is based on net/master, then applied you patch on top of it,
>> commit id is 2ab9fb18c46b91b16a0f0f329336d3be9fc32deb.
>
>
> Xiaolong, it may be more helpful to show the base tree where we apply
> the patch to. And the final url:
>
> https://github.com/0day-ci/linux/tree/Eric-Dumazet/net-__skb_flow_dissect-must-cap-its-return-value/20161110-080839
>
> Thanks,
> Fengguang

Is there any chance you guys could send me the net/ethernet/eth.o and
drivers/net/ethernet/intel/igb/igb.o files for this build?  I'm still
not able to reproduce but I have a thought that this might be some
sort of compiler issue.

Specifically looking over the call trace it looks like we only pulled
8 bytes of the header instead of 14.  This is based on the values of
RAX and R15 differing by 6 which I believe represent skb->len and
skb->data_len  However eth_get_headlen is supposed to be using
sizeof(*eth) which should be 14.  I'm wondering if there is an issue
due to it being a packed structure that is resulting in 8 being
reported instead of 14.

Thanks.

- Alex
