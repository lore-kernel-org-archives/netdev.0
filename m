From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] act_mirred: don't clone skb when skb isn't shared
Date: Sat, 5 Jun 2010 21:07:55 +0800
Message-ID: <AANLkTikHqzIr-SjPZe-iiMPxVG9PRR9-0A9qeMwzfLYp@mail.gmail.com>
References: <1275658990-15838-1-git-send-email-xiaosuo@gmail.com>
	<1275742435.3490.31.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:45980 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933329Ab0FENIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 09:08:15 -0400
Received: by pvg16 with SMTP id 16so916990pvg.19
        for <netdev@vger.kernel.org>; Sat, 05 Jun 2010 06:08:15 -0700 (PDT)
In-Reply-To: <1275742435.3490.31.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 5, 2010 at 8:53 PM, jamal <hadi@cyberus.ca> wrote:
> On Fri, 2010-06-04 at 21:43 +0800, Changli Gao wrote:
>> don't clone skb when skb isn't shared
>>
>> When the tcf_action is TC_ACT_STOLEN, and the skb isn't shared, we don't need
>> to clone a new skb. As the skb will be freed after this function returns, we
>> can use it freely once we get a reference to it.
>
> It looks like a good optimization - but i am not a big fan of one-offs
> [because usability goes down and I am forced to explain it longer in the
> rules (refer to: Documentation/networking/tc-actions-env-rules.txt)]

Thanks. BTW: act_nat.c doesn't obey the following rule, and you plan
to remove TC_MUNGED and TC_OK2MUNGE?

2) If you munge any packet thou shalt call pskb_expand_head in the case
someone else is referencing the skb. After that you "own" the skb.
You must also tell us if it is ok to munge the packet (TC_OK2MUNGE),
this way any action downstream can stomp on the packet.

>
> How about you update skb_act_clone to take take the action code as well
> and do the check the if stolen/queued it does a skb_get otherwise it
> calls skb_clone?
>

Good idea. Thanks.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
