From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: Re: [PATCH net] dsa: fix promiscuity leak on slave dev open error
Date: Sun, 28 Jun 2015 16:19:28 +0300
Message-ID: <CAOtvUMd0iFYDhFQT6CFvYvvTjGCNYRX2i2vqJaXf3m=+2z=_jw@mail.gmail.com>
References: <1435240213-15179-1-git-send-email-giladb@ezchip.com>
	<20150626150401.GH9469@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Gilad Ben-Yossef <giladb@ezchip.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Scott Feldman <sfeldma@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:35690 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751429AbbF1NT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2015 09:19:29 -0400
Received: by lagh6 with SMTP id h6so26855732lag.2
        for <netdev@vger.kernel.org>; Sun, 28 Jun 2015 06:19:28 -0700 (PDT)
In-Reply-To: <20150626150401.GH9469@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 26, 2015 at 6:04 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Thu, Jun 25, 2015 at 04:50:13PM +0300, giladb@ezchip.com wrote:
>> From: Gilad Ben-Yossef <gilad@benyossef.com>
>>
>> DSA master netdev promiscuity counter was not being properly
>> decremented on slave device open error path.
>>
...

> Acked-by: Andrew Lunn <andrew@lunn.ch>

Thank you Andrew.
>
> FYI: I grep'ed the whole kernel. This seems to be the only place 0 is
> passed to dev_set_promiscuity(), i.e. the same bug is not present
> anywhere else.
>


It has occurred to me that dev_set_promiscuity() and its brethren
dev_set_allmulti() may not be the best of interfaces:

- On cursory inspection of code using these function their name
implies the value of the relevant counter is set to the value passed
as parameter, not incremented by it.
- No caller I've managed to spot passes anything but -1 or 1

It seems an interface of

int dev_set_promiscuity(struct net_device *dev, bool on);

int dev_set_allmulti(struct net_device *dev, bool on);

would be as functional (for current users), more readable and less
error prone but I am not sure such a tiny problem (if you can call
this a problem) is worth the churn...


Gilad






-- 
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"If you take a class in large-scale robotics, can you end up in a
situation where the homework eats your dog?"
 -- Jean-Baptiste Queru
