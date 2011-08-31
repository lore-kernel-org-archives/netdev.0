From: Ben Greear <greearb@candelatech.com>
Subject: Re: [patch net-next-2.6 1/2] net: allow to change carrier via sysfs
Date: Wed, 31 Aug 2011 13:48:22 -0700
Message-ID: <4E5E9E16.6060502@candelatech.com>
References: <1314715608-978-1-git-send-email-jpirko@redhat.com>	 <1314715608-978-2-git-send-email-jpirko@redhat.com>	 <CAHXqBFJh0xjRYv_-2AzwAvpHOUfQ+pD_153qVtNA3Ybo9r3b=w@mail.gmail.com>	 <20110831082655.GB2010@minipsycho.brq.redhat.com>	 <CAHXqBFJpSZNhkur7QNYbjG-=Bkq2HtHKEHsn+H3TnEJ5NezJoA@mail.gmail.com>	 <20110831084511.GD2010@minipsycho.brq.redhat.com>	 <4E5E939C.5000009@gmail.com> <1314821537.3274.24.camel@bwh-desktop> <4E5E9A30.1040105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Jiri Pirko <jpirko@redhat.com>,
	=?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, shemminger@vyatta.com
To: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:40446 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754673Ab1HaUsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 16:48:38 -0400
In-Reply-To: <4E5E9A30.1040105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/31/2011 01:31 PM, Nicolas de Peslo=C3=BCan wrote:
> Le 31/08/2011 22:12, Ben Hutchings a =C3=A9crit :
>> On Wed, 2011-08-31 at 22:03 +0200, Nicolas de Peslo=C3=BCan wrote:
>>> Le 31/08/2011 10:45, Jiri Pirko a =C3=A9crit :
>>>
>>>>>>> Do you expect drivers using implementation different than just =
calling
>>>>>>> netif_carrier_on/off? Or is it supposed to also e.g. power down=
 PHYs?
>>>>>> Yes, generally it can be used also for en/disable phy, for testi=
ng
>>>>>> purposes if hw and driver would support it.
>>>>>
>>>>> I'd like to see this working for GRE tunnel devices (for keepaliv=
e
>>>>> daemon to be able to indicate to routing daemons whether tunnel i=
s
>>>>> really working) - implementation would be identical to dummy's ca=
se.
>>>>> Should I prepare a patch or can I leave it to you?
>>>>
>>>> Ok, I can include it to this patchset (I'm going to repost first p=
atch
>>>> anyway)
>>>
>>> Can't we assume that the dummy's case is the default behavior and
>>> register this default
>>> ndo_change_carrier callback for every device ?
>>
>> You have got to be joking. No device driver that has real link
>> monitoring should use this implementation.
>
> Well, why not? Arguably, this is probably not the feature one would u=
se every day, but...
>
> Testing a cluster reaction to a link down event would be easier if on=
e doesn't need to unplug the cable for the test. I understand that one =
can turn off the
> switch port (physical or virtual), but echo 0 > /sys/class/net/eth0/c=
arrier would be nice too.

There is special hardware out there that can do bypass, and often it al=
so has a mode
that will programatically cut link by throwing some relays.  We use thi=
s for our
testing equipment...

If there is some way to twiddle standard-ish hardware to actually drop =
link, that
would be neat.  I'd think it should be an ethtool type of thing, howeve=
r.

Actually dropping link, and letting that naturally propagate up the sta=
ck seems
more reasonable than lying about the status half way up the stack.

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
