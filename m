From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: ipconfig: allow IP-Config over DSA devices
Date: Thu, 5 Jun 2014 10:47:15 -0700
Message-ID: <CAGVrzcbu6vCKDdDuz+aPCxFGL3rhSREugb17Y_sAzSLmg9Jvaw@mail.gmail.com>
References: <1401473326-21828-1-git-send-email-f.fainelli@gmail.com> <20140605.000132.501712848318656492.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f48.google.com ([209.85.216.48]:64243 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055AbaFERr4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 13:47:56 -0400
Received: by mail-qa0-f48.google.com with SMTP id i13so1868362qae.35
        for <netdev@vger.kernel.org>; Thu, 05 Jun 2014 10:47:55 -0700 (PDT)
In-Reply-To: <20140605.000132.501712848318656492.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-06-05 0:01 GMT-07:00 David Miller <davem@davemloft.net>:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Fri, 30 May 2014 11:08:45 -0700
>
>> Let me know your thoughts. If you feel like something like:
>> netdev_is_upper_dev() or something like that is better.
>
> I'm not happy with this change for several reasons.
>
> First, I don't like the idea that ipconfig works for some stacked
> devices and not for others.

Right, although as I described DSA devices are likely to be the only
real kernel-only created devices here, other stacked devices such as
bonds, vlans and tunnels for instance do require either kernel
modifications to be created by the kernel, or user-space.

>  I'd rather that we simply accept that
> direct devices are the only thing supported.

Would you be willing to revise this position if we can come up with a
generic infrastructure for telling whether a network device depends on
another one and its master device needs to be opened first? Should we
instead force the slave devices in net/dsa/slave.c to open its master
device if it is not UP?

>
> Secondly, the logic in that ipconfig loop is so confusing.  I can't
> even figure out what that dsa pointer test is trying to really
> accomplish in the second hunk of your patch.
>
> I'd like to defer this for now, sorry.

Thanks for your comments.
-- 
Florian
