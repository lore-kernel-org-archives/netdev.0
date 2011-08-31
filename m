From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6 1/2] net: allow to change carrier via sysfs
Date: Wed, 31 Aug 2011 22:03:40 +0200
Message-ID: <4E5E939C.5000009@gmail.com>
References: <1314715608-978-1-git-send-email-jpirko@redhat.com> <1314715608-978-2-git-send-email-jpirko@redhat.com> <CAHXqBFJh0xjRYv_-2AzwAvpHOUfQ+pD_153qVtNA3Ybo9r3b=w@mail.gmail.com> <20110831082655.GB2010@minipsycho.brq.redhat.com> <CAHXqBFJpSZNhkur7QNYbjG-=Bkq2HtHKEHsn+H3TnEJ5NezJoA@mail.gmail.com> <20110831084511.GD2010@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, bhutchings@solarflare.com,
	shemminger@vyatta.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:51376 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755209Ab1HaUDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 16:03:41 -0400
Received: by wwe5 with SMTP id 5so533416wwe.1
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2011 13:03:40 -0700 (PDT)
In-Reply-To: <20110831084511.GD2010@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 31/08/2011 10:45, Jiri Pirko a =C3=A9crit :

>>>> Do you expect drivers using implementation different than just cal=
ling
>>>> netif_carrier_on/off? Or is it supposed to also e.g. power down PH=
Ys?
>>> Yes, generally it can be used also for en/disable phy, for testing
>>> purposes if hw and driver would support it.
>>
>> I'd like to see this working for GRE tunnel devices (for keepalive
>> daemon to be able to indicate to routing daemons whether tunnel is
>> really working) - implementation would be identical to dummy's case.
>> Should I prepare a patch or can I leave it to you?
>
> Ok, I can include it to this patchset (I'm going to repost first patc=
h
> anyway)

Can't we assume that the dummy's case is the default behavior and regis=
ter this default=20
ndo_change_carrier callback for every device ?

Device drivers willing to do something different can install a differen=
t callback if appropriate.

This would avoid duplicating the following code in most drivers, that d=
on't need something special.

static int dummy_change_carrier(struct net_device *dev, bool new_carrie=
r)
{
	if (new_carrier)
		netif_carrier_on(dev);
	else
		netif_carrier_off(dev);
	return 0;
}

If someone is not confident with this default callback registered for a=
ll device, at least, we can=20
put this code in a common place, so that a driver willing to use it doe=
sn't need to have its own=20
version of it.

	Nicolas.
