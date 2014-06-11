From: Wei-Chun Chao <weichunc@plumgrid.com>
Subject: Re: [PATCH net] net: fix UDP tunnel GSO of frag_list GRO packets
Date: Wed, 11 Jun 2014 07:36:33 -0700
Message-ID: <CACviX4FS5rt26p1qRzjjS=sUeEb-8hcrFa8xh8mi+WbkJfQF5Q@mail.gmail.com>
References: <1402296534-8978-1-git-send-email-weichunc@plumgrid.com>
	<20140611.004904.2053967979976189800.davem@davemloft.net>
	<CAJZOPZ+C5M9aYY26R05JNF67fFfUj-VwS85ufWzerzMwS0HBNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f177.google.com ([209.85.128.177]:56458 "EHLO
	mail-ve0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753971AbaFKOge (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 10:36:34 -0400
Received: by mail-ve0-f177.google.com with SMTP id oz11so6499199veb.36
        for <netdev@vger.kernel.org>; Wed, 11 Jun 2014 07:36:33 -0700 (PDT)
In-Reply-To: <CAJZOPZ+C5M9aYY26R05JNF67fFfUj-VwS85ufWzerzMwS0HBNA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Wed, Jun 11, 2014 at 10:49 AM, David Miller <davem@davemloft.net> wrote:
>> From: Wei-Chun Chao <weichunc@plumgrid.com>
>> Date: Sun,  8 Jun 2014 23:48:54 -0700
>>
>>> This patch fixes a kernel BUG_ON in skb_segment. It is hit when
>>> testing two VMs on openvswitch with one VM acting as VXLAN gateway.
>>>
>>> During VXLAN packet GSO, skb_segment is called with skb->data
>>> pointing to inner TCP payload. skb_segment calls skb_network_protocol
>>> to retrieve the inner protocol. skb_network_protocol actually expects
>>> skb->data to point to MAC and it calls pskb_may_pull with ETH_HLEN.
>>> This ends up pulling in ETH_HLEN data from header tail. As a result,
>>> pskb_trim logic is skipped and BUG_ON is hit later.
>>>
>>> Move skb_push in front of skb_network_protocol so that skb->data
>>> lines up properly.
>>  ...
>>> Signed-off-by: Wei-Chun Chao <weichunc@plumgrid.com>
>>
>> Applied, thank you.
>
> Hi Wei-Chun,
>
> So how long the bug exists? was it introduced 3.15-rc cycle or
> earlier? I guess it needs to go into -stable  too, right?
>
> Or.

I think this has been there since 3.10 -
commit 19acc327258ac5bcd0f31c07853e6d9784010fb4

Thanks,
Weichun
