From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6 1/2] net: allow to change carrier via sysfs
Date: Wed, 31 Aug 2011 22:31:44 +0200
Message-ID: <4E5E9A30.1040105@gmail.com>
References: <1314715608-978-1-git-send-email-jpirko@redhat.com>	 <1314715608-978-2-git-send-email-jpirko@redhat.com>	 <CAHXqBFJh0xjRYv_-2AzwAvpHOUfQ+pD_153qVtNA3Ybo9r3b=w@mail.gmail.com>	 <20110831082655.GB2010@minipsycho.brq.redhat.com>	 <CAHXqBFJpSZNhkur7QNYbjG-=Bkq2HtHKEHsn+H3TnEJ5NezJoA@mail.gmail.com>	 <20110831084511.GD2010@minipsycho.brq.redhat.com>	 <4E5E939C.5000009@gmail.com> <1314821537.3274.24.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>,
	=?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, shemminger@vyatta.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49852 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754579Ab1HaUbo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 16:31:44 -0400
Received: by wyh22 with SMTP id 22so457653wyh.19
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2011 13:31:43 -0700 (PDT)
In-Reply-To: <1314821537.3274.24.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 31/08/2011 22:12, Ben Hutchings a =C3=A9crit :
> On Wed, 2011-08-31 at 22:03 +0200, Nicolas de Peslo=C3=BCan wrote:
>> Le 31/08/2011 10:45, Jiri Pirko a =C3=A9crit :
>>
>>>>>> Do you expect drivers using implementation different than just c=
alling
>>>>>> netif_carrier_on/off? Or is it supposed to also e.g. power down =
PHYs?
>>>>> Yes, generally it can be used also for en/disable phy, for testin=
g
>>>>> purposes if hw and driver would support it.
>>>>
>>>> I'd like to see this working for GRE tunnel devices (for keepalive
>>>> daemon to be able to indicate to routing daemons whether tunnel is
>>>> really working) - implementation would be identical to dummy's cas=
e.
>>>> Should I prepare a patch or can I leave it to you?
>>>
>>> Ok, I can include it to this patchset (I'm going to repost first pa=
tch
>>> anyway)
>>
>> Can't we assume that the dummy's case is the default behavior and
>> register this default
>> ndo_change_carrier callback for every device ?
>
> You have got to be joking.  No device driver that has real link
> monitoring should use this implementation.

Well, why not? Arguably, this is probably not the feature one would use=
 every day, but...

Testing a cluster reaction to a link down event would be easier if one =
doesn't need to unplug the=20
cable for the test. I understand that one can turn off the switch port =
(physical or virtual), but=20
echo 0 > /sys/class/net/eth0/carrier would be nice too.

Of course, I assume that netif_carrier_on and netif_carrier_off are onl=
y called on real link status=20
change. So the value written into /sys/class/net/eth0/carrier would sta=
y until the link revert it,=20
due to a double status change (up-down-up or down-up-down). But I may m=
iss totally this point.

	Nicolas.
