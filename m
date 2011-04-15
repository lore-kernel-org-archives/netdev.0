From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: The bonding driver should notify userspace of MAC address change
Date: Fri, 15 Apr 2011 20:40:20 +0200
Message-ID: <4DA89114.9040900@gmail.com>
References: <20110415184407.550abd88@pomiocik.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, roy@marples.name,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: =?UTF-8?B?TWljaGHFgiBHw7Nybnk=?= <mgorny@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55468 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751976Ab1DOSkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 14:40:25 -0400
Received: by wwa36 with SMTP id 36so3534118wwa.1
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 11:40:24 -0700 (PDT)
In-Reply-To: <20110415184407.550abd88@pomiocik.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/04/2011 18:44, Micha=C5=82 G=C3=B3rny a =C3=A9crit :
> Hello,
>
> I'd like to file a feature request for the bonding driver. Currently,
> there is no way for userspace to know whether the driver actually get=
s
> a MAC address. This results in the fact that dhcpcd sends MAC-less DH=
CP
> packets through bonding device if it is started before bond gets any
> slaves.

A similar subject, involving bridge instead of bonding, was discussed a=
 few weeks ago in this=20
thread: http://marc.info/?l=3Dlinux-netdev&m=3D129939017116310&w=3D2

In particular, I suggested to apply Stephen's suggestion not only to br=
idge but also to bonding.

(http://marc.info/?l=3Dlinux-netdev&m=3D129948385024680&w=3D2)

A bonding device should not report link up to userspace until at least =
one slave is present and up.

And possibly, a bonding device should report link down if all slaves ar=
e down or all slave were removed.

Jay, Andy, does this sounds sensible to you?

> I've reported that problem upstream [1], and the author suggested tha=
t
> the bonding driver would have to notify the userspace about MAC addre=
ss
> change, suggesting using RTM_NEWLINK message.
>
> I wanted to write a patch for that but I don't seem to see any
> appropriate IFF_* flag for that particular kind of event. dhcpcd auth=
or
> suggested using 'ifi->ifi_change =3D ~0U' but I'm not sure if it's
> appropriate.
>
> Could you either add such a kind of notification or give me a tip on
> how to proceed with adding it? Thanks in advance.
>
> [1] http://roy.marples.name/projects/dhcpcd/ticket/212

