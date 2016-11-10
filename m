From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [patch net-next 5/8] Introduce sample tc action
Date: Thu, 10 Nov 2016 12:16:26 -0800
Message-ID: <5824D59A.2000804@gmail.com>
References: <1478776988-5400-1-git-send-email-jiri@resnulli.us>
 <1478776988-5400-6-git-send-email-jiri@resnulli.us>
 <5824CBFE.5030502@gmail.com> <5824CCB0.4090302@gmail.com>
 <AM3PR05MB07594EA6AE3C0D4C71FEA155ACB80@AM3PR05MB0759.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        Ido Schimmel <idosch@mellanox.com>,
        Elad Raz <eladr@mellanox.com>,
        Nogah Frankel <nogahf@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "geert+renesas@glider.be" <geert+renesas@glider.be>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "linux@roeck-us.net" <linux@roeck-us.net>,
        "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>
To: Yotam Gigi <yotamg@mellanox.com>, Jiri Pirko <jiri@resnulli.us>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33204 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933923AbcKJUQu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 15:16:50 -0500
Received: by mail-pf0-f196.google.com with SMTP id 144so5273459pfv.0
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 12:16:50 -0800 (PST)
In-Reply-To: <AM3PR05MB07594EA6AE3C0D4C71FEA155ACB80@AM3PR05MB0759.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-10 11:58 AM, Yotam Gigi wrote:
> 
> 
>> -----Original Message-----
>> From: John Fastabend [mailto:john.fastabend@gmail.com]
>> Sent: Thursday, November 10, 2016 9:38 PM
>> To: Jiri Pirko <jiri@resnulli.us>; netdev@vger.kernel.org
>> Cc: davem@davemloft.net; Yotam Gigi <yotamg@mellanox.com>; Ido Schimmel
>> <idosch@mellanox.com>; Elad Raz <eladr@mellanox.com>; Nogah Frankel
>> <nogahf@mellanox.com>; Or Gerlitz <ogerlitz@mellanox.com>;
>> jhs@mojatatu.com; geert+renesas@glider.be; stephen@networkplumber.org;
>> xiyou.wangcong@gmail.com; linux@roeck-us.net; roopa@cumulusnetworks.com
>> Subject: Re: [patch net-next 5/8] Introduce sample tc action
>>
>> On 16-11-10 11:35 AM, John Fastabend wrote:
>>> On 16-11-10 03:23 AM, Jiri Pirko wrote:
>>>> From: Yotam Gigi <yotamg@mellanox.com>
>>>>
>>>> This action allow the user to sample traffic matched by tc classifier.
>>>> The sampling consists of choosing packets randomly, truncating them,
>>>> adding some informative metadata regarding the interface and the original
>>>> packet size and mark them with specific mark, to allow further tc rules to
>>>> match and process. The marked sample packets are then injected into the
>>>> device ingress qdisc using netif_receive_skb.
>>>>
>>>> The packets metadata is packed using the ife encapsulation protocol, and
>>>> the outer packet's ethernet dest, source and eth_type, along with the
>>>> rate, mark and the optional truncation size can be configured from
>>>> userspace.
>>>>
>>>> Example:
>>>> To sample ingress traffic from interface eth1, and redirect the sampled
>>>> the sampled packets to interface dummy0, one may use the commands:
>>>>
>>>> tc qdisc add dev eth1 handle ffff: ingress
>>>>
>>>> tc filter add dev eth1 parent ffff: \
>>>> 	   matchall action sample rate 12 mark 17
>>>>
>>>> tc filter add parent ffff: dev eth1 protocol all \
>>>> 	   u32 match mark 17 0xff \
>>>> 	   action mirred egress redirect dev dummy0
>>>>
>>>> Where the first command adds an ingress qdisc and the second starts
>>>> sampling every 12'th packet on dev eth1 and marks the sampled packets with
>>>> 17. The third command catches the sampled packets, which are marked with
>>>> 17, and redirects them to dev dummy0.
>>>
>>> The sampling algorithm was not randomized based on the above commit
>>> log? It really needs to be for all the reasons Roopa mentioned earlier.
>>> Did I miss some email on why it didn't get implemented?
>>>
>>> Also there was an indication the already is actually implemented
>>> correctly so don't we need the hw/sw to behave the same. The whole
>>> argument about sw/hw parity, etc.
>>
>> sorry bit of a typo there corrected 2nd paragraph here...
>>
>> Also there was an indication the hardware is already implemented \
>> correctly so don't we need the hw/sw to behave the same. The argument
>> about sw/hw parity, etc.
> 
> Our hardware currently does not support sampling with random behavior, so 
> we did implement it in software too. 
> 
> But, the API is extensible and it is possible to add a random keyword to 
> the tc action to allow random sampling. In that case, the keyword will be
> implemented in sw only and our driver will fail offloading it.
> 

For many use cases this will be limiting but OK maybe this is good
enough for something and we can add a flag/attribute to support random
sampling. Works for me.
