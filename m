From: Gao Feng <fgao@ikuai8.com>
Subject: Re: [PATCH net v2 1/1] net: batman-adv: Treat NET_XMIT_CN as transmit successfully
Date: Mon, 21 Nov 2016 21:31:59 +0800
Message-ID: <CA+6hz4p9sRHsmNS+x+MsEfx774=C08UJvaFqaRYund3+9dw91w@mail.gmail.com>
References: <1479725922-5112-1-git-send-email-fgao@ikuai8.com>
 <20161121110915.GB22120@breakpoint.cc> <CA+6hz4rVCL2oxeQUojcqptNfcZdtLZdgEA2_j7iU1-B=s12SHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: mareklindner@neomailbox.ch,
        Simon Wunderlich <sw@simonwunderlich.de>, a@unstable.cc,
        "David S. Miller" <davem@davemloft.net>,
        b.a.t.m.a.n@lists.open-mesh.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpproxy19.qq.com ([184.105.206.84]:52694 "EHLO
        smtpproxy19.qq.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753261AbcKUNcJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 08:32:09 -0500
Received: from mail-vk0-f48.google.com (unknown [209.85.213.48])
        by esmtp4.qq.com (ESMTP) with SMTP id 0
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 21:32:00 +0800 (CST)
Received: by mail-vk0-f48.google.com with SMTP id 137so218791771vkl.0
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 05:32:01 -0800 (PST)
In-Reply-To: <CA+6hz4rVCL2oxeQUojcqptNfcZdtLZdgEA2_j7iU1-B=s12SHg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,


On Mon, Nov 21, 2016 at 9:24 PM, Gao Feng <fgao@ikuai8.com> wrote:
> Hi Florian,
>
> On Mon, Nov 21, 2016 at 7:09 PM, Florian Westphal <fw@strlen.de> wrote:
>> fgao@ikuai8.com <fgao@ikuai8.com> wrote:
>>> From: Gao Feng <fgao@ikuai8.com>
>>>
>>> The tc could return NET_XMIT_CN as one congestion notification, but
>>> it does not mean the packet is lost. Other modules like ipvlan,
>>> macvlan, and others treat NET_XMIT_CN as success too.
>>>
>>> So batman-adv should add the NET_XMIT_CN check.
>>
>> "The tc could return NET_XMIT_CN as one congestion notification, but
>> it means another packet got dropped. Other modules like batman do not
>> treat NET_XMIT_CN as success, so modules like ipvlan, macvlan, ..
>> should ignore it as well."

I didn't get you in the last email

You mean the NET_XMIT_CN should be treated as one error?
But the comment of NET_XMIT_CN says "It indicates that the device will
soon be dropping packets, or already drops some packets of the same
priority". It is not sure another packet is dropped.

BTW, the macro "net_xmit_eval" does not treat NET_XMIT_CN as one error.

Regards
Feng

>>
>> What I am asking is:
>> Are you sure adding NET_XMIT_CN handling everywhere is the right way to
>> resolve the inconsistency?
>
> Or create one new macro to handle this case like net_xmit_eval.
> For example,
> #define net_xmit_ok(ret)    (ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)
>
> Is it ok? But it should be done for net-next.
>
> Best Regards
> Feng
