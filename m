From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: Bridge stays down until a port is added
Date: Mon, 26 Sep 2011 22:02:21 +0200
Message-ID: <4E80DA4D.3090404@gmail.com>
References: <20110811070659.GA21307@torres.zugschlus.de>	<20110811081706.7307e8b2@nehalam.ftrdhcpuser.net>	<20110917204257.GA2636@torres.zugschlus.de>	<1316550027.1783.102.camel@dcbw.foobar.com>	<20110925082504.GA32712@torres.zugschlus.de> <20110926084743.35cb2ccc@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marc Haber <mh+netdev@zugschlus.de>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38746 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753013Ab1IZUCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 16:02:13 -0400
Received: by wyg34 with SMTP id 34so6272461wyg.19
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2011 13:02:12 -0700 (PDT)
In-Reply-To: <20110926084743.35cb2ccc@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 26/09/2011 17:47, Stephen Hemminger a =E9crit :
> The root of this whole problem is really that IPv6 reports addresses
> in a tentative state to applications that can not be passed to the bi=
nd() system call.
> For most cases, this problem never happens because the tentative addr=
esses are
> resolved by Duplicate Address Detection before the application starts=
=2E But
> I have seen (and fixed) this happen before this whole discussion star=
ted.
>
> 1. The problem is not unique to bridges. It happens with bridge, macv=
tap,
>     even on wireless networks where the device is available but carri=
er is
>     not asserted.
>
> 2. Any change to what the kernel does (like not reporting tentative a=
ddresses)
>     would break applications even worse.
>
> 3. When the bridge was always reporting carrier, it was in effect bre=
aking
>     IPv6 Duplicate Address Detection. And that is bad.

Stephen,

What do you think about a generic per-interface option that would cause=
 bind() to accept tentative=20
address hold by a particular interface? This of course violate IPv6 pri=
nciple, but we are talking=20
about interfaces that are unable to do DAD, either permanently or until=
 something happens on the=20
underlying device.

echo 1 > /sys/class/net/br0/allow_bind_on_tentative_address
echo 1 > /sys/class/net/dummy0/allow_bind_on_tentative_address
echo 1 > /sys/class/net/wlan0/allow_bind_on_tentative_address
and so on...

And we may possibly automatically reset this option to 0 if DAD eventua=
lly causes the address to be=20
considered duplicate.

	Nicolas.
