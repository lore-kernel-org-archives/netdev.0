From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH next 3/3] net: Use l3_dev instead of skb->dev for L3 processing
Date: Thu, 3 Mar 2016 17:42:44 -0800
Message-ID: <CAF2d9jhgoWeZdPkM-aev6j9a8OjUQ78CbE7dgp1wPXu91qp_-A@mail.gmail.com>
References: <1456783704-18746-1-git-send-email-mahesh@bandewar.net>
 <CAM_iQpXmoSZhNw+CCbFw5b6Dzq4W+vt5WH8FmRc1ZiuJgv1xnQ@mail.gmail.com>
 <CAF2d9jhopDVGxsSM3wfYh2XgENebJNbEOn9D7Vb8t13bQ7dRcQ@mail.gmail.com>
 <CAF2d9jiyjThgeQKw==tKRk3Sh0dNfzUdwJciwsVGPFLdb9uGTA@mail.gmail.com> <CAM_iQpUB_b3S_Mi8QyzhX_XBog3+ZshY8xbSby5eUytnG2OQRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>, Tim Hockin <thockin@google.com>,
	Alex Pollitt <alex.pollitt@metaswitch.com>,
	Matthew Dupre <matthew.dupre@metaswitch.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f175.google.com ([209.85.161.175]:33529 "EHLO
	mail-yw0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756774AbcCDBnF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 20:43:05 -0500
Received: by mail-yw0-f175.google.com with SMTP id b72so30937432ywe.0
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 17:43:05 -0800 (PST)
In-Reply-To: <CAM_iQpUB_b3S_Mi8QyzhX_XBog3+ZshY8xbSby5eUytnG2OQRg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> As you mentioned logically we should be able to pass the skb in master's
>>> ns
>>> until L3 processing is completed. This patch series attempts to do that by
>>> disassociating this logic from skb->dev and adding it to l3_dev. This
>>> should
>>> include not just IPT but all that is done in L3 phase (IPT, routing etc.)
>>> Also since dev->l3_dev is same as dev, this should not break any existing
>>> logic.
>>>
>> Well, looking at the code I realized that I missed few places (especially
>> routing
>> logic) which continues using skb->dev in ingress path and should be
>> corrected to
>> use l3_dev. I'll correct those places and send the next version.
>
>
> Look, even you yourself are missing something here. ;) This is exactly why
> I suggest to consider another approach. Please don't introduce any code
> that is hard to debug even for yourself. The struct net pointer is passed
> around in kernel network subsystem almost everywhere, it is not easy to make
> it bug-free by just switching skb->dev.
>
I disagree. Conceptually this is very easy to understand as we are taking L3
processing off of skb->dev and loading it onto dev->l3_dev. So
everything that is
associated with l3_dev is for L3. This should neither make debugging harder
nor add complicated code.

>
>>> That's the generic implementation as far as the stack is concerned and
>>> IPvlan
>>> uses it to make the IPT hooks symmetric.
>>>
>>> Another IPT hook may be good enough (however I haven't
>>> given much thought to it) for IPvlan, but this generic approach will be
>>> for
>>> whole of L3. Also currently this I have implemented for the ingress path
>>> but that does not mean the same cannot be extended for the egress path
>>> (in fact I'm thinking about that)
>>
>
> This is logically correct and easier to understand or debug, since IPT hook
> is very common in network subsystem even ingress qdisc uses it.
