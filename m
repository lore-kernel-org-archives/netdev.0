From: Gao Feng <fgao@ikuai8.com>
Subject: Re: [PATCH net v2 1/1] net: batman-adv: Treat NET_XMIT_CN as transmit successfully
Date: Mon, 21 Nov 2016 21:24:37 +0800
Message-ID: <CA+6hz4rVCL2oxeQUojcqptNfcZdtLZdgEA2_j7iU1-B=s12SHg@mail.gmail.com>
References: <1479725922-5112-1-git-send-email-fgao@ikuai8.com> <20161121110915.GB22120@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: mareklindner@neomailbox.ch,
        Simon Wunderlich <sw@simonwunderlich.de>, a@unstable.cc,
        "David S. Miller" <davem@davemloft.net>,
        b.a.t.m.a.n@lists.open-mesh.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbgsg2.qq.com ([54.254.200.128]:52099 "EHLO smtpbgsg2.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754393AbcKUNZG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Nov 2016 08:25:06 -0500
Received: from mail-vk0-f54.google.com (unknown [209.85.213.54])
        by esmtp4.qq.com (ESMTP) with SMTP id 0
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 21:24:39 +0800 (CST)
Received: by mail-vk0-f54.google.com with SMTP id x186so218281773vkd.1
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 05:24:40 -0800 (PST)
In-Reply-To: <20161121110915.GB22120@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On Mon, Nov 21, 2016 at 7:09 PM, Florian Westphal <fw@strlen.de> wrote:
> fgao@ikuai8.com <fgao@ikuai8.com> wrote:
>> From: Gao Feng <fgao@ikuai8.com>
>>
>> The tc could return NET_XMIT_CN as one congestion notification, but
>> it does not mean the packet is lost. Other modules like ipvlan,
>> macvlan, and others treat NET_XMIT_CN as success too.
>>
>> So batman-adv should add the NET_XMIT_CN check.
>
> "The tc could return NET_XMIT_CN as one congestion notification, but
> it means another packet got dropped. Other modules like batman do not
> treat NET_XMIT_CN as success, so modules like ipvlan, macvlan, ..
> should ignore it as well."
>
> What I am asking is:
> Are you sure adding NET_XMIT_CN handling everywhere is the right way to
> resolve the inconsistency?

Or create one new macro to handle this case like net_xmit_eval.
For example,
#define net_xmit_ok(ret)    (ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)

Is it ok? But it should be done for net-next.

Best Regards
Feng
