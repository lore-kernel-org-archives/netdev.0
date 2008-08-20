From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [GIT]: Networking
Date: Wed, 20 Aug 2008 08:15:46 +0200
Message-ID: <1219212946.7591.303.camel@violet.holtmann.net>
References: <alpine.LFD.1.10.0808191411390.3324@nehalem.linux-foundation.org>
	 <20080819.142735.179034162.davem@davemloft.net>
	 <alpine.LFD.1.10.0808191432040.3324@nehalem.linux-foundation.org>
	 <20080819.144015.40311904.davem@davemloft.net>
	 <alpine.LFD.1.10.0808191446560.3324@nehalem.linux-foundation.org>
	 <20080819222612.GA16766@2ka.mipt.ru>
	 <alpine.LFD.1.10.0808191536100.3324@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53322 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801AbYHTGPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 02:15:42 -0400
In-Reply-To: <alpine.LFD.1.10.0808191536100.3324@nehalem.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Linus,

> > I belive it was you who told that there is no black and white (another 
> > guy told that there is no spoon, I frequntly confuse).
> 
> Yes.
> 
> > Any changes made no matter when can not be 100% tested in laboratory 
> > environment, even fixes, which look obviously.
> 
> 100% agreed.
> 
> Please note that I'm not against these things slipping in occasionally. 
> The reason I brought this up in the first place really wasn't the loopback 
> driver issue at all. The reason I brought it up was simply the fact that 
> when I compare the size and frequency of changes, the networking pulls 
> tend to be the worst of the lot of the "core" kernel changes.
> 
> I say "core" kernel changes, because things are usually worse for the 
> outliers. As mentioned, networking is actually one of the _better_ guys if 
> you start comparing to the DVB people, or to some of the architectures 
> that often slip the merge window _entirely_, and *all* their changes come 
> in during -rc2 or something.
> 
> So it's not that networking is especially bad on an absolute scale in this 
> regard. And it's not like it doesn't happen all the time for everybody 
> else too. But I think networking has ben a bit more cavalier about things 
> than many other core areas.

I was always under the impression that Dave was quite strict when it
comes to merging things after the merge window. Yes, some things should
have better waiting for the next release, but we always had exceptions
for various things that fall out of the merge window anyway.

All the small "soldiers" like me make a call on what to pick to send to
Dave and it is not that we try to sneak anything in. It just made sense
to us and either he agrees or not. Some choices are better than others,
no questions asked, but I think what you are seeing is that networking
is getting huge. And this is mostly networking drivers. And I don't
expect this to slow down or anything. The Linux WiFi support is just at
the edge to really become competitive and show real leading across all
other operating systems.

When looking at the actual split between net/ and drivers/, then the
drivers part is the big one. And I don't expect this to go down any time
soon. We are about to get Ultra-Wideband support merged. After that we
will have plain networking over UWB, Wireless USB using UWB and soon
Bluetooth over UWB. Also we will see Bluetooth over 802.11 and then
another Ultra-Low-Power thing for sensor devices. And I forget WiMAX.
That is just the short term wireless future. Every of these come with
new networking drivers and then you have new Ethernet drivers and so on.
It is just a lot of stuff.

While looking at the actual diffstat, I realized that I really was the
biggest offender:

net/bluetooth/hci_sysfs.c                   |  376 ++++++++++++++-------------

This is actually the regression fix. It is big, because thanks to sysfs,
I had to move some code around in that file and rename things. I should
have seen that earlier and gave Dave an extra comment why it is so big.
That was my bad. Sorry for that.

Regards

Marcel


