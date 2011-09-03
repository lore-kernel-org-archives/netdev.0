From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH 1/2] bridge: leave carrier on for empty bridge
Date: Sat, 03 Sep 2011 20:32:28 +0200
Message-ID: <4E6272BC.4020707@gmail.com>
References: <20110902172220.830228928@vyatta.com>	<20110902172247.396753508@vyatta.com>	<4E614CF7.7030700@gmail.com> <20110902151100.327af0bf@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34817 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751098Ab1ICSc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Sep 2011 14:32:29 -0400
Received: by wyh22 with SMTP id 22so2687798wyh.19
        for <netdev@vger.kernel.org>; Sat, 03 Sep 2011 11:32:28 -0700 (PDT)
In-Reply-To: <20110902151100.327af0bf@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/09/2011 00:11, Stephen Hemminger a =E9crit :
> On Fri, 02 Sep 2011 23:39:03 +0200
> Nicolas de Peslo=FCan<nicolas.2p.debian@gmail.com>  wrote:
>
>> Le 02/09/2011 19:22, Stephen Hemminger a =E9crit :
>>> This resolves a regression seen by some users of bridging.
>>> Some users use the bridge like a dummy device.
>>> They expect to be able to put an IPv6 address on the device
>>> with no ports attached during boot.
>>>
>>> Note: the bridge still will reflect the state of ports in the
>>> bridge if there are any added.
>>
>> Doesn't this jeopardize the behavior introduced in 1faa4356a3bd89ea1=
1fb92752d897cff3a20ec0e
>> "bridge: control carrier based on ports online"?
>>
>> If the user starts the DHCP client before adding the first port to t=
he bridge, the DHCP client will
>> have a carrier and start the autoconfiguration process. This was the=
 old behavior, but you fixed it.
>>
>> 	Nicolas.
>>
>
> There is no perfect solution.
> If DHCP works then IPv6 breaks?

Instead of asserting carrier when the bridge have no port, can't we ass=
ert carrier when the three=20
following condition are true at the same time :

- The bridge have no port.
- At least one IP address is setup on the bridge.
- The two above conditions are true for more than a configurable amount=
 of seconds, with a default=20
of 10, for example.

This would only delay carrier on for a few seconds for the regression a=
nd keep the current behavior=20
(carrier off until at least 1 port is on) for DHCP.

	Nicolas.
