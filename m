From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net] net: fix UDP tunnel GSO of frag_list GRO packets
Date: Wed, 11 Jun 2014 13:45:27 +0300
Message-ID: <CAJZOPZ+C5M9aYY26R05JNF67fFfUj-VwS85ufWzerzMwS0HBNA@mail.gmail.com>
References: <1402296534-8978-1-git-send-email-weichunc@plumgrid.com>
	<20140611.004904.2053967979976189800.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>,
	Wei-Chun Chao <weichunc@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f52.google.com ([209.85.216.52]:35359 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726AbaFKKp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 06:45:28 -0400
Received: by mail-qa0-f52.google.com with SMTP id w8so4037004qac.11
        for <netdev@vger.kernel.org>; Wed, 11 Jun 2014 03:45:27 -0700 (PDT)
In-Reply-To: <20140611.004904.2053967979976189800.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 11, 2014 at 10:49 AM, David Miller <davem@davemloft.net> wrote:
> From: Wei-Chun Chao <weichunc@plumgrid.com>
> Date: Sun,  8 Jun 2014 23:48:54 -0700
>
>> This patch fixes a kernel BUG_ON in skb_segment. It is hit when
>> testing two VMs on openvswitch with one VM acting as VXLAN gateway.
>>
>> During VXLAN packet GSO, skb_segment is called with skb->data
>> pointing to inner TCP payload. skb_segment calls skb_network_protocol
>> to retrieve the inner protocol. skb_network_protocol actually expects
>> skb->data to point to MAC and it calls pskb_may_pull with ETH_HLEN.
>> This ends up pulling in ETH_HLEN data from header tail. As a result,
>> pskb_trim logic is skipped and BUG_ON is hit later.
>>
>> Move skb_push in front of skb_network_protocol so that skb->data
>> lines up properly.
>  ...
>> Signed-off-by: Wei-Chun Chao <weichunc@plumgrid.com>
>
> Applied, thank you.

Hi Wei-Chun,

So how long the bug exists? was it introduced 3.15-rc cycle or
earlier? I guess it needs to go into -stable  too, right?

Or.
