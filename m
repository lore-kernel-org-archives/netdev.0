From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH] bonding: reset queue mapping prior to transmission to
 physical device
Date: Thu, 02 Jun 2011 22:13:57 +0200
Message-ID: <4DE7EF05.8030505@gmail.com>
References: <20110602185659.GA2749@hmsreliant.think-freely.org>	<1307041789.2812.27.camel@bwh-desktop>	<20110602194621.GB2749@hmsreliant.think-freely.org> <20110602.130448.917724318321380583.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nhorman@tuxdriver.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33973 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753354Ab1FBUOB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 16:14:01 -0400
Received: by wya21 with SMTP id 21so914943wya.19
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2011 13:14:00 -0700 (PDT)
In-Reply-To: <20110602.130448.917724318321380583.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/06/2011 22:04, David Miller a =E9crit :
> From: Neil Horman<nhorman@tuxdriver.com>
> Date: Thu, 2 Jun 2011 15:46:21 -0400
>
>> Potentially, yes.  I only fixed this because I was looking at bondin=
g and its
>> queue_mapping behavior, and saw that this needed fixing.  Bridging a=
nd IP
>> forwarding should also likely clear the queue mapping in the forward=
ing path
>> somewhere to avoid selecting an output tx queue that is a function o=
f whatever
>> queue and device it arrived on during ingress.  I've not yet looked =
to see if
>> thats already being done.
>
> No we do not do this, intentionally.
>
> That way the input classification and queue selection is mirrored
> on the transmit side, which we absolutely want to happen.

Can you confirm that this is the expected behavior for IP forwarding an=
d bridge but not for bonding?

To be more precise, due to the way bonding use queue mapping for slave =
selection, it is desirable to=20
clear the mapping before sending to the slave, because the meaning of t=
he mapping for the slave=20
interface might be really different from the meaning for the bonding in=
terface. Arguably, this is=20
the mapping usage in bonding which is "different" from other usages, bu=
t...

	Nicolas.
