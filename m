From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/3] staging/rtl8192e: use s8 instead of char
Date: Wed, 20 Jul 2016 18:00:26 +0200
Message-ID: <8046944.AyQGVaNKWH@wuerfel>
References: <20160719153403.2967812-1-arnd@arndb.de> <3876342.AU5AfU16PB@wuerfel> <wrfjk2ggpbmw.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-wireless@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Mateusz Kulikowski <mateusz.kulikowski@gmail.com>,
	devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org,
	Andrea Merello <andrea.merello@gmail.com>
To: Jes Sorensen <Jes.Sorensen@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.134]:50815 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751783AbcGTQAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 12:00:41 -0400
In-Reply-To: <wrfjk2ggpbmw.fsf@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, July 20, 2016 11:33:43 AM CEST Jes Sorensen wrote:
> Arnd Bergmann <arnd@arndb.de> writes:
> > On Wednesday, July 20, 2016 7:25:19 AM CEST Jes Sorensen wrote:
> >> Arnd Bergmann <arnd@arndb.de> writes:
> >> Well it really all depends on how much time I have and how much others
> >> step up and help contribute to the code. For rtl8xxxu my plans are as
> >> follows:
> >> 
> >> 1) rtl8188eu support, since this is the most widely distributed USB
> >> dongle which isn't currently supported by a non staging driver. I am
> >> currently working on this together with Andrea Merello.
> >
> > Ok, cool.
> >
> >> 2) Beacon support for IBSS and AP mode - hopefully this should make it
> >> possible to default rtl8xxxu for rtl8192cu/rtl8188cu devices and disable
> >> them in rtlwifi.
> >
> > Do we have any indication that those two actually work in rtlwifi at the
> > moment? My experience seems to match the recommendations for all the
> > raspberry pi users that use yet another (worse looking) driver:
> >
> > https://github.com/raspberrypi/linux/commit/9ee31007a5032a3afe2fcb20c36b34f0ad57df56
> 
> I am not really authoritative on that one. I tried it in station mode
> and it didn't work well for me. I never played with AP mode - It may
> work better in IBSS or AP mode than it does in station mode. I don't
> like to pull the rug away under people, which is why I haven't pushed
> for this.

Right. Then again, for AP mode, all information on the web indicates
similar problems, recommending the out-of-tree driver and a custom
hostap fork:

https://bogeskov.dk/UsbAccessPoint.html

> > throughput for me is 2mbit/s, compared to my intel 2x2 wireless that gets
> > 5mbit/s on the same network, but I guess that doesn't really mean much
> > as long as I have problems with the infrastructure.
> 
>  Note the rtl8xxxu driver doesn't report speeds properly to
> NetworkMangler or 'iw' as the API for this relies on confirmed TX
> speeds, and I only have an easy way of retrieving RX speeds from the RTL
> device. The vendor driver probably fakes it.

This was the rx speed I got from downloading a file from a known server.
With the rtl8192cu driver, I could get no connection at all today,
and when I last tried, it stopped working after a few minutes at best.

> > This one:
> > Bus 001 Device 033: ID 0bda:8171 Realtek Semiconductor Corp. RTL8188SU
> > 802.11n WLAN Adapter
> >
> > I bought the rtl8188su a while ago, while the rtl8188cus (0bda:8176)
> > is from this year. According to https://wikidevi.com/wiki/Realtek, it
> > seems to be one year older than the rtl8188cus and was almost as common
> > in its day. Apparently everyone that used to make ...su device replaced it
> > with a ...cu or the newer ...eu chips and that is all you can buy these days
> > on the low end.
> 
> Gotcha, 8188su is the 1x1 version of it. I do have a 8192su in the
> drawer somewhere, but the TODO list is a bit long already 

Yes, I was just agreeing here that it's not worth doing that one.
As far as I can see, the evolution of these devices is

RTL81xxU (2008)
RTL81xxSU (2009)
RTL81xxCU (2010)
RTL81xxEU (2013)

Clearly there is no use working on the older ones before the latest
ones work well.

	Arnd
