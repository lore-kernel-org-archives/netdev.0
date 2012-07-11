From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: UDP ordering when using multiple rx queue
Date: Wed, 11 Jul 2012 15:41:55 +0200
Message-ID: <CAL8zT=hi9_Y4oGw=cVSnYE=km6MZBAAie-A5RWLy=47FR8aTag@mail.gmail.com>
References: <CAL8zT=g5nHd6FprhxFc21XTgfXeaokt4QN1fS4ekcNVkuvZE9g@mail.gmail.com>
 <1342004939.27284.28.camel@lb-tlvb-meravs.il.broadcom.com> <CAL8zT=jMPCv_Lc7gJYGHRhHZop9aWJfp2w1o_cD0Z8SRdtck7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Merav Sicron <meravs@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35877 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757741Ab2GKNmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 09:42:17 -0400
Received: by wibhr14 with SMTP id hr14so1152266wib.1
        for <netdev@vger.kernel.org>; Wed, 11 Jul 2012 06:42:16 -0700 (PDT)
In-Reply-To: <CAL8zT=jMPCv_Lc7gJYGHRhHZop9aWJfp2w1o_cD0Z8SRdtck7Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/7/11 Jean-Michel Hautbois <jhautbois@gmail.com>:
> 2012/7/11 Merav Sicron <meravs@broadcom.com>:
>> On Wed, 2012-07-11 at 00:53 -0700, Jean-Michel Hautbois wrote:
>>
>>> Several tests lead to a simple conclusion : when the NIC has only one
>>> RX queue, everything is ok (like be2net for instance), but when it has
>>> more than one RX queue, then I can have "lost packets".
>>> This is the case for bnx2x or mlx4 for instance.
>> >From what you describe I assume that you use different source IP /
>> destination IP in each packet - is this something that you can control?
>> Because with the same IP addresses the traffic will be steered to the
>> same queue.
>
> OK, sorry for not having explained that : the packets are multicast
> with a port for each stream. Sending one stream multicast on a bnx2x
> based NIC can lead to several queues used (two, for what I can see)
> and then, to the problem reported.
>
>>> Here are my questions :
>>> - Is it possible to force a driver to use only one rx queue, even if
>>> it can use more without reloading the driver (and this is feasible
>>> only when a parameter exists for that !) ?
>> You can reduce the number of queues using "ethtool -L ethX combined 1".
>> Note however that it will cause automatic driver unload/load.
>
> OK, thanks for this tip :).
>
> JM

I confirm that using ethtool -L eth1 combined 1 solves my issue.
I can have 3Gbps per sec with 5 multicast on 5 ports without any
"packet loss" (again, for my application) and it uses one RX queue
only (of course :)).
One multicast (one port) but with the default combined=8 splits in two
rx queues...
Unicast traffic seems ok (I used netperf in order to check this assumption).

JM
