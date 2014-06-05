From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH 1/3] net: phylib: add adjust_state callback to phy device
Date: Thu, 05 Jun 2014 09:14:30 +0200
Message-ID: <539018D6.4000806@zonque.org>
References: <1401872439-30107-1-git-send-email-zonque@gmail.com> <1401872439-30107-2-git-send-email-zonque@gmail.com> <CAGVrzcYfa6rwhqpZ8NB9Za0WdJDi3eePoYLcHsqQnUhuP3ui=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, marek.belisko@gmail.com,
	Matus Ujhelyi <ujhelyi.m@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:33800 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750827AbaFEHOe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2014 03:14:34 -0400
In-Reply-To: <CAGVrzcYfa6rwhqpZ8NB9Za0WdJDi3eePoYLcHsqQnUhuP3ui=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On 06/05/2014 07:11 AM, Florian Fainelli wrote:
> 2014-06-04 2:00 GMT-07:00 Daniel Mack <zonque@gmail.com>:
>> Allow phy drivers to take action when the core does its link adjustment.
>> No change for drivers that do not implement this callback.
> 
> This sounds potentially dangerous if misused, PHY drivers would
> basically be allowed to do arbitrary link state changes based on their
> custom needs.

Yes, and this is basically what my quirk handler does. It takes action
when the link goes down (PHY_NOLINK), as we unfortunately need to reset
the chip every time this happens.

> I really need to review your workaround here to better
> understand whether we can come up with a solution that allows for less
> liberty in PHY drivers.

Sure, any other way of calling back to the PHY when the core enters the
PHY_NOLINK state would do. I just thought that an adjust_state callback
is most versatile, but I understand that it could be misused.


Thanks for having a look!

Daniel
