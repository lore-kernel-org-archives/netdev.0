From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: ethtool physical identify vs netlink locking?
Date: Wed, 30 Mar 2011 03:35:40 +0200
Message-ID: <AANLkTi=um5CecqdXeqBNKHv4nWk7-bZ27aL5=bXFi0SE@mail.gmail.com>
References: <20110329135252.116bf5e0@s6510> <1301443676.10056.57.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:36670 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753785Ab1C3BgB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2011 21:36:01 -0400
Received: by qwk3 with SMTP id 3so524208qwk.19
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2011 18:36:00 -0700 (PDT)
In-Reply-To: <1301443676.10056.57.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/3/30 Ben Hutchings <bhutchings@solarflare.com>:
> On Tue, 2011-03-29 at 13:52 -0700, Stephen Hemminger wrote:
>> Right now if an administrator uses the ethtool function to identify =
network
>> interface, the netlink lock can be held indefinitely. In other words=
, doing
>> "ethtool -p eth1" will stop all other netlink activity. This is bad,=
 imagine
>> the case of an operator doing that to find a NIC in a rack, and beca=
use of
>> the netlink lockout all routing daemon activity stops.
[...]
>> There are several possible solutions but most involve fixing all the=
 device
>> drivers (24). Options:
>>
>> 1. Have device driver drop and reacquire rtnl() while blinking
>> 2. Have ethtool core drop rtnl before calling device driver
>> 3. Add per-device ethtool rtnl lock
> 4. Define a ethtool operation 'set_id_state' with an argument that se=
ts
> identification on/off/inactive/active (the last optional, for any dri=
ver
> that really wants to do this differently). =C2=A0When this is defined=
, the
> ethtool core runs the loop and acquires the lock each time it calls t=
his
> operation.

5. Have a driver register a LED class device instead of implementing
an ethtool op.

Hmm. This would require changes to userspace ethtool command. I wonder
if anything else uses this call?

Best Regards,
Micha=C5=82 Miros=C5=82aw
