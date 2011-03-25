From: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Subject: Re: disabling ipv6 (when ipv6 module is already loaded or built in)
Date: Fri, 25 Mar 2011 23:53:06 +0100
Message-ID: <201103252353.06297.a.miskiewicz@gmail.com>
References: <201103251817.04583.a.miskiewicz@gmail.com> <4D8CF970.7020601@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:33308 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753179Ab1CYWxL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2011 18:53:11 -0400
Received: by ewy4 with SMTP id 4so657680ewy.19
        for <netdev@vger.kernel.org>; Fri, 25 Mar 2011 15:53:10 -0700 (PDT)
In-Reply-To: <4D8CF970.7020601@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 25 of March 2011, Brian Haley wrote:
> On 03/25/2011 01:17 PM, Arkadiusz Miskiewicz wrote:
> > Hi,
> >=20
> > There are two options for disabling some ipv6 functionality in ipv6
> > module - disable and disable_ipv6. The second option is also availa=
ble
> > as sysctl and can be switched runtime.
> >=20
> > First is nicer because it also prevents apps from creating sockets =
by
> > using socket(AF_INET6, ...). Various apps use AF_INET6 socket creat=
ion
> > to deterine if ipv6 is supported on the system. Unfortunately "disa=
ble"
> > one doesn't exist as sysctl and this is a problem.
> >=20
> > Is it possible to make "disable" sysctl option, too? Currently ther=
e is
> > no runtime way to disable ipv6 (or I'm unaware of such way).
>=20
> Not really, the module parameter causes IPv6 to be loaded just enough=
 to
> allow other modules that rely on it to load, but it never registers
> any of the protocol handlers, sysctls, tables, etc. to make it usable=
=2E
> And the IPv6 module isn't unloadable, so you have to reboot to change
> this setting.
>=20
> When there are no addresses it's not very usable since you can't send
> out packets...

The whole problem is that socket(AF_INET6,...) is allowed. If setting=20
net.ipv6.conf.all.disable_ipv6=3D1 would also prevent such socket() fro=
m=20
succeeding then everything would be fine.

> -Brian

--=20
Arkadiusz Mi=C5=9Bkiewicz        PLD/Linux Team
arekm / maven.pl            http://ftp.pld-linux.org/
