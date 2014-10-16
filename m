From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] openvswitch: fix a use after free
Date: Thu, 16 Oct 2014 16:58:49 +0200
Message-ID: <CAEP_g=9dcPGNTFTL729yFFSUzyZ7OHQaVa9cJLGihqdoT+X66g@mail.gmail.com>
References: <1413450075-5044-1-git-send-email-roy.qing.li@gmail.com> <1413468747.28798.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: roy.qing.li@gmail.com, netdev <netdev@vger.kernel.org>,
	Andy Zhou <azhou@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog133.obsmtp.com ([74.125.149.82]:52264 "HELO
	na3sys009aog133.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751273AbaJPO7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2014 10:59:10 -0400
Received: by mail-qc0-f169.google.com with SMTP id o8so2924930qcw.14
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2014 07:59:09 -0700 (PDT)
In-Reply-To: <1413468747.28798.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 16, 2014 at 4:12 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2014-10-16 at 17:01 +0800, roy.qing.li@gmail.com wrote:
>>
>>               arp = (struct arp_eth_header *)skb_network_header(skb);
>>
>> -             if (arphdr_ok(skb) &&
>> +             if (arp_t &&
>>                   arp->ar_hrd == htons(ARPHRD_ETHER) &&
>>                   arp->ar_pro == htons(ETH_P_IP) &&
>>                   arp->ar_hln == ETH_ALEN &&
>
> Fixes: 0714812134d7d ("openvswitch: Eliminate memset() from flow_extract.")
>
> By doing this bug hunting, you also can CC bug author so that he knows
> what happened. Maybe he will avoid similar mistakes in the future.

Yes, this one is my fault. Thanks for tracking it down.
