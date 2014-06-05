From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/3] net: phylib: add adjust_state callback to phy device
Date: Thu, 5 Jun 2014 11:12:09 -0700
Message-ID: <CAGVrzcbas_A=prheBFeczuC+gRyWdACVrAHY0_zhy0N+fePTWQ@mail.gmail.com>
References: <1401872439-30107-1-git-send-email-zonque@gmail.com>
 <1401872439-30107-2-git-send-email-zonque@gmail.com> <CAGVrzcYfa6rwhqpZ8NB9Za0WdJDi3eePoYLcHsqQnUhuP3ui=w@mail.gmail.com>
 <539018D6.4000806@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"marek.belisko" <marek.belisko@gmail.com>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:61356 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757AbaFESMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 14:12:50 -0400
Received: by mail-qg0-f52.google.com with SMTP id a108so2226601qge.25
        for <netdev@vger.kernel.org>; Thu, 05 Jun 2014 11:12:49 -0700 (PDT)
In-Reply-To: <539018D6.4000806@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

2014-06-05 0:14 GMT-07:00 Daniel Mack <daniel@zonque.org>:
> Hi Florian,
>
> On 06/05/2014 07:11 AM, Florian Fainelli wrote:
>> 2014-06-04 2:00 GMT-07:00 Daniel Mack <zonque@gmail.com>:
>>> Allow phy drivers to take action when the core does its link adjustment.
>>> No change for drivers that do not implement this callback.
>>
>> This sounds potentially dangerous if misused, PHY drivers would
>> basically be allowed to do arbitrary link state changes based on their
>> custom needs.
>
> Yes, and this is basically what my quirk handler does. It takes action
> when the link goes down (PHY_NOLINK), as we unfortunately need to reset
> the chip every time this happens.

In fact, the callback name is sort of a misnomer here, as you are not
really adjusting the PHY device state here, you are reading from it to
do something about the PHY device based on this state.

Could you rename it to "state_notify" for instance to make it clear
that this must absolutely be a read-only operation and the PHY driver
is by no means allow to mess with the PHY device structure at all?
Constifying the phy_device argument here would not really help
unfortunately, and providing you with just the 'state' as a RO
argument would not help either since you need to access the PHY
device...

>
>> I really need to review your workaround here to better
>> understand whether we can come up with a solution that allows for less
>> liberty in PHY drivers.
>
> Sure, any other way of calling back to the PHY when the core enters the
> PHY_NOLINK state would do. I just thought that an adjust_state callback
> is most versatile, but I understand that it could be misused.

I was thinking about having a notifier callchain here that would
execute synchronously and in the same context as your proposed
adjust_link() callback, although that might be be too heavy weighted
for basically just one notified callback.

>
>
> Thanks for having a look!
>
> Daniel
>



-- 
Florian
