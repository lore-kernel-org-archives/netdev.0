From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH 1/3] net: phylib: add adjust_state callback to phy device
Date: Thu, 05 Jun 2014 23:39:15 +0200
Message-ID: <5390E383.50805@zonque.org>
References: <1401872439-30107-1-git-send-email-zonque@gmail.com> <1401872439-30107-2-git-send-email-zonque@gmail.com> <CAGVrzcYfa6rwhqpZ8NB9Za0WdJDi3eePoYLcHsqQnUhuP3ui=w@mail.gmail.com> <539018D6.4000806@zonque.org> <CAGVrzcbas_A=prheBFeczuC+gRyWdACVrAHY0_zhy0N+fePTWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"marek.belisko" <marek.belisko@gmail.com>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:52524 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751559AbaFEVjT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2014 17:39:19 -0400
In-Reply-To: <CAGVrzcbas_A=prheBFeczuC+gRyWdACVrAHY0_zhy0N+fePTWQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On 06/05/2014 08:12 PM, Florian Fainelli wrote:
> 2014-06-05 0:14 GMT-07:00 Daniel Mack <daniel@zonque.org>:

>>> This sounds potentially dangerous if misused, PHY drivers would
>>> basically be allowed to do arbitrary link state changes based on their
>>> custom needs.
>>
>> Yes, and this is basically what my quirk handler does. It takes action
>> when the link goes down (PHY_NOLINK), as we unfortunately need to reset
>> the chip every time this happens.
> 
> In fact, the callback name is sort of a misnomer here, as you are not
> really adjusting the PHY device state here, you are reading from it to
> do something about the PHY device based on this state.
> 
> Could you rename it to "state_notify" for instance to make it clear
> that this must absolutely be a read-only operation and the PHY driver
> is by no means allow to mess with the PHY device structure at all?
> Constifying the phy_device argument here would not really help
> unfortunately, and providing you with just the 'state' as a RO
> argument would not help either since you need to access the PHY
> device...

Sure, I can rename it, no problem.

> I was thinking about having a notifier callchain here that would
> execute synchronously and in the same context as your proposed
> adjust_link() callback, although that might be be too heavy weighted
> for basically just one notified callback.

Plus, it wouldn't really solve the issue you described above, right?


I'll resend after -rc1 is out, with the changed name for the callback.


Again, thanks!
Daniel
