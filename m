From: Ben Greear <greearb@candelatech.com>
Subject: Re: [patch net-next-2.6 1/2] net: allow to change carrier via sysfs
Date: Wed, 31 Aug 2011 14:49:43 -0700
Message-ID: <4E5EAC77.3030504@candelatech.com>
References: <1314715608-978-1-git-send-email-jpirko@redhat.com>  <1314715608-978-2-git-send-email-jpirko@redhat.com>  <CAHXqBFJh0xjRYv_-2AzwAvpHOUfQ+pD_153qVtNA3Ybo9r3b=w@mail.gmail.com>  <20110831082655.GB2010@minipsycho.brq.redhat.com>  <CAHXqBFJpSZNhkur7QNYbjG-=Bkq2HtHKEHsn+H3TnEJ5NezJoA@mail.gmail.com>  <20110831084511.GD2010@minipsycho.brq.redhat.com>  <4E5E939C.5000009@gmail.com> <1314821537.3274.24.camel@bwh-desktop>  <4E5E9A30.1040105@gmail.com>  <4E5E9E16.6060502@candelatech.com> <1314826605.3274.34.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>, Jiri Pirko <jpirko@redhat.com>,
	=?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, shemminger@vyatta.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:52914 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755751Ab1HaVtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 17:49:53 -0400
In-Reply-To: <1314826605.3274.34.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/31/2011 02:36 PM, Ben Hutchings wrote:
> On Wed, 2011-08-31 at 13:48 -0700, Ben Greear wrote:
>> On 08/31/2011 01:31 PM, Nicolas de Peslo=C3=BCan wrote:
>>> Le 31/08/2011 22:12, Ben Hutchings a =C3=A9crit :
>>>> On Wed, 2011-08-31 at 22:03 +0200, Nicolas de Peslo=C3=BCan wrote:
>>>>> Le 31/08/2011 10:45, Jiri Pirko a =C3=A9crit :
>>>>>
>>>>>>>>> Do you expect drivers using implementation different than jus=
t calling
>>>>>>>>> netif_carrier_on/off? Or is it supposed to also e.g. power do=
wn PHYs?
>>>>>>>> Yes, generally it can be used also for en/disable phy, for tes=
ting
>>>>>>>> purposes if hw and driver would support it.
>>>>>>>
>>>>>>> I'd like to see this working for GRE tunnel devices (for keepal=
ive
>>>>>>> daemon to be able to indicate to routing daemons whether tunnel=
 is
>>>>>>> really working) - implementation would be identical to dummy's =
case.
>>>>>>> Should I prepare a patch or can I leave it to you?
>>>>>>
>>>>>> Ok, I can include it to this patchset (I'm going to repost first=
 patch
>>>>>> anyway)
>>>>>
>>>>> Can't we assume that the dummy's case is the default behavior and
>>>>> register this default
>>>>> ndo_change_carrier callback for every device ?
>>>>
>>>> You have got to be joking. No device driver that has real link
>>>> monitoring should use this implementation.
>>>
>>> Well, why not? Arguably, this is probably not the feature one would=
 use every day, but...
>>>
>>> Testing a cluster reaction to a link down event would be easier if =
one doesn't need to unplug the cable for the test. I understand that on=
e can turn off the
>>> switch port (physical or virtual), but echo 0>  /sys/class/net/eth0=
/carrier would be nice too.
>>
>> There is special hardware out there that can do bypass, and often it=
 also has a mode
>> that will programatically cut link by throwing some relays.  We use =
this for our
>> testing equipment...
>>
>> If there is some way to twiddle standard-ish hardware to actually dr=
op link, that
>> would be neat.  I'd think it should be an ethtool type of thing, how=
ever.
>
> We need to be able to control this as part of our driver test suite (=
on
> the peer, not the device under test).  There are various MDIO bits th=
at
> look like they should do this but unfortunately they don't have
> consistent effects.  Besides that, many PHYs are not MDIO-manageable.
> So this would have to be a device-specific operation, whether it's
> exposed through ethtool or sysfs.

Well, I have boxes that can act as the peer.  Nics are intel chipset 1G=
,
the bypass/link-drop feature is some separate hardware on the NIC, and
there is a hack of a driver & user-space tools that controls those bits=
=2E

But, if there is a way to fiddle normal NICs w/out the special bypass/d=
isconnect
hardware, that would be welcome.  Even if it's different for each drive=
r, and
not supported by all, ethtool can deal with that sort of thing.

Here's a link to the hardware we use...it comes with drivers, though we=
've hacked on
ours a bit.

http://silicom-usa.com/upload/Downloads/Product_102.pdf

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
