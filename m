From: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Subject: Re: Setting RPS affinities from network driver
Date: Tue, 24 Feb 2015 15:42:03 +0530
Message-ID: <CA+sq2CeEAsSg-x+yX4kcougRZkOV3J6_eNwhVpzGEnr4EiF5rA@mail.gmail.com>
References: <CA+mtBx9inCEq7PS3h02tSThsMLBVv5OUrusDkMg7d-OOvmqdiQ@mail.gmail.com>
	<CAPFHKzc-z4LUkxO+nSB=az25ynr=m5KaudQHYNhYi=VtRafEkw@mail.gmail.com>
	<CA+mtBx-ZW3jVzaXicGi5okS5egMkfi8-SaDX_ewy-k5zRONfmg@mail.gmail.com>
	<20150223.221403.1719458030396280283.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <therbert@google.com>, jonathon.reinhart@gmail.com,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:55280 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752506AbbBXKMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 05:12:05 -0500
Received: by mail-wi0-f170.google.com with SMTP id ex7so3354912wid.1
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 02:12:03 -0800 (PST)
In-Reply-To: <20150223.221403.1719458030396280283.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the valuable information.

Just to give more info on why i want think it is better to have this
config from driver,
- The SOC i am working on has multiple cores and has on-board ethernet
interface which supports upto 40Gbps.
- It is highly difficult to achieve any meaningful performance with
default RPS config.
- So currently i am setting RPS config such that the CPU which takes
high amount of interrupts/packets from receive queue doesn't do the
processing as well.
- This is improving network performance with single flow.

So thought if its possible to do this from driver itself instead
relying on user space scripts. As you guys have pointed i will try to
implement a generic API
instead of exporting 'rps_needed'. Will try to submit this very soon.

Thanks,
Sunil.


On Tue, Feb 24, 2015 at 8:44 AM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Fri, 20 Feb 2015 15:05:11 -0800
>
>>> Note that this argument is different from RSS where we're dealing with
>>> actual hardware queues, so the driver of course has a say in the
>>> configuration.
>>
>> Assuming that all queues are equal and we have a standard way to
>> influence the indirection table, even RSS configuration really isn't
>> driver specific configuration. We just need to know how many queues
>> are available.
>
> Agreed.
>
> If drivers start doing this, fine, but they must do it with a common
> piece of infrastructure that each and every driver can (easily) plug
> into and make use of.
>
> Even better would be something that was so generic that the driver's
> don't actualy implement any part of it other than responding to what
> the generic networking core asks it to do.
