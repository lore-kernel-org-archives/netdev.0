From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v3 net-next] pktgen: introduce 'rx' mode
Date: Sat, 02 May 2015 09:01:27 -0700
Message-ID: <5544F4D7.50202@plumgrid.com>
References: <1430457130-16003-1-git-send-email-ast@plumgrid.com> <20150502104621.4fede885@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Robert Olsson <robert@herjulf.net>,
	Ben Greear <greearb@candelatech.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:37153 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751336AbbEBQB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2015 12:01:29 -0400
Received: by igblo3 with SMTP id lo3so56621509igb.0
        for <netdev@vger.kernel.org>; Sat, 02 May 2015 09:01:28 -0700 (PDT)
In-Reply-To: <20150502104621.4fede885@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/2/15 1:46 AM, Jesper Dangaard Brouer wrote:
> On Thu, 30 Apr 2015 22:12:10 -0700
> Alexei Starovoitov <ast@plumgrid.com> wrote:
>
>> Introduce 'RX' mode for pktgen which generates the packets
>> using familiar pktgen commands, but feeds them into
>> netif_receive_skb() instead of ndo_start_xmit().
>>
>> It is designed to test netif_receive_skb and ingress qdisc
>> performace only. Make sure to understand how it works before
>> using it for other rx benchmarking.
>
> Hi Alexei
>
> First of all I love the idea of modifying pktgen to performance test
> the RX path.
>
> I'm not sure the simple "rx" flag is a good "name".  It likely
> conflicts with other work where pktgen can receive it own packets, e.g.
> https://people.kth.se/~danieltt/pktgen/ or Ben Greer's solution.
>
> In your patch several things are not pktgen "compliant":
>   1. Flags in pktgen are normally in upper-case "RX"
>   2. Flags also require a disable "!RX" option
>   3. You didn't add the flag to list of supported flags
>   4. You don't output if the flag is enabled
>   5. You didn't update the documentation (Documentation/networking/pktgen.txt)

It's actually not a flag, because it cannot be disabled by design.
It cannot be flipped back and forth, because it affects what other
real flags can be applied. It's a _mode_.
I don't see yet how I can safely switch this mode back into tx while
things are running. It would need a whole new mechanism of stopping
things and so on. I wanted to start simple.
For 5, yeah, agree, need to update the doc.
As far as name, I don't have preferences. Will 'stack_inject' sound
better? I can respin with that name if you like, but disabling it on
the fly is a major change. I'd rather do it in small steps.
