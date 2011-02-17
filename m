From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Question about tg3 and bnx2 driver suppliers
Date: Thu, 17 Feb 2011 15:17:35 +0100
Message-ID: <1297952255.2604.115.camel@edumazet-laptop>
References: <3BA51C2C-B28F-4FED-BF5D-B9BF46EAF3F7@highwire.stanford.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Michael Durket <durket@highwire.stanford.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:47319 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753995Ab1BQORm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 09:17:42 -0500
Received: by fxm20 with SMTP id 20so2639628fxm.19
        for <netdev@vger.kernel.org>; Thu, 17 Feb 2011 06:17:40 -0800 (PST)
In-Reply-To: <3BA51C2C-B28F-4FED-BF5D-B9BF46EAF3F7@highwire.stanford.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 17 f=C3=A9vrier 2011 =C3=A0 05:24 -0800, Michael Durket a =C3=A9=
crit :
> I'm trying to fix a problem with packet drops and frame errors (reall=
y
> rxbds_empty and rx_discards (or rx_fw_discards depending on whether o=
r
> not its a tg3 supported chip or a bnx2 chip)). We have this happening
> on pretty much all the RedHat 5.x systems we're running these drivers
> on. In investigating what remedies to employ to fix this, I'm trying
> to determine if new versions of this driver are supplied by Broadcom,
> or by people within the Linux community so=20
> I can find the right place to ask questions about it. I'm pretty sure
> this isn't the right list for these types of questions, but if someon=
e
> could tell me whether I should be contacting Broadcom directly, or th=
e
> name of some other Linux mailing list or forum that might help, I'd
> appreciate it.
>=20

It _is_ the right place, dont worry ;)

One possible cause of packet drops is when softirqs are disabled for to=
o
long periods, even if NIC has a big RX ring (check ethtool -g eth0)

We fixed one big offender some weeks ago : iptables -L

=46ix is in commit 83723d60717f8da0f53f

http://git2.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commitdiff;h=3D83723d60717f8da0f53f91cf42a845ed56c09662



