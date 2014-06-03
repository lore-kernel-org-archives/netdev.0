From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/1] driver: net: smsc911x: set NOCARRIER flag in driver initialization
Date: Tue, 3 Jun 2014 09:29:24 -0700
Message-ID: <CAGVrzcYTtBm1EdXdyjV8-CmFH=JE0xdtsQGwSL9cqC4y5z2JKA@mail.gmail.com>
References: <5380EAF6.1090402@gmail.com> <20140529.152809.871745461296745132.davem@davemloft.net>
 <CAHPKR9KmDSgC9EstJLfhqY9SB462OSJhQCEPS7Ka=VvnqbH6iQ@mail.gmail.com>
 <20140530.134245.1805237850303710369.davem@davemloft.net> <CAHPKR9+H1gmJBqtO-4c7YBQrx+xbLenzWE6sky9Pq7=yF4bHUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Balakumaran Kannan <kumaran.4353@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f48.google.com ([209.85.216.48]:57903 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932786AbaFCQaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 12:30:06 -0400
Received: by mail-qa0-f48.google.com with SMTP id i13so5226628qae.7
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2014 09:30:04 -0700 (PDT)
In-Reply-To: <CAHPKR9+H1gmJBqtO-4c7YBQrx+xbLenzWE6sky9Pq7=yF4bHUw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-06-03 7:15 GMT-07:00 Balakumaran Kannan <kumaran.4353@gmail.com>:
> On Sat, May 31, 2014 at 2:12 AM, David Miller <davem@davemloft.net> wrote:
>> From: Balakumaran Kannan <kumaran.4353@gmail.com>
>> Date: Fri, 30 May 2014 18:35:43 +0530
>>
>>> All these drivers call netif_carrier_off function after registering
>>> the network device using register_netdev.
>>
>> I can quote more counter-examples than your list, starting with the
>> Broadcom tg3 driver.
>
> Thank you David for this information. I'll send updated patch as version-2.
>
> Still I couldn't understand the reason behind this. I should be grateful if you
> would explain me little bit.

I believe one reason is that as soon as you call register_netdev(),
the network device notifiers run as part of call_netdevice_notifiers()
and it is valid for a notified callback to open your network device.
This means that you can call the driver's ndo_open() before you
returned from register_netdev(). If netif_carrier_off() is called
after register_netdev(), there is a risk for ndo_open() not to get a
consistent carrier state, and the actual call to netif_carrier_off()
to mess things up.
-- 
Florian
