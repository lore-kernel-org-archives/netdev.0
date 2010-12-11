From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] rfc: ethtool: early-orphan control
Date: Sat, 11 Dec 2010 09:03:38 +0100
Message-ID: <1292054618.2746.48.camel@edumazet-laptop>
References: <1292040815-10439-1-git-send-email-horms@verge.net.au>
	 <20101211042434.GB32453@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55939 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885Ab0LKIDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Dec 2010 03:03:44 -0500
Received: by wyb28 with SMTP id 28so4230548wyb.19
        for <netdev@vger.kernel.org>; Sat, 11 Dec 2010 00:03:42 -0800 (PST)
In-Reply-To: <20101211042434.GB32453@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 11 d=C3=A9cembre 2010 =C3=A0 13:24 +0900, Simon Horman a =C3=A9=
crit :
> On Sat, Dec 11, 2010 at 01:13:35PM +0900, Simon Horman wrote:
> > Early orphaning is an optimisation which avoids unnecessary cache m=
isses by
> > orphaning an skb just before it is handed to a device for transmit =
thus
> > avoiding the case where the orphaning occurs on a different CPU.
> >=20
> > In the case of bonded devices this has the unfortunate side-effect =
of
> > breaking down flow control allowing a socket to send UDP packets as=
 fast as
> > the CPU will allow. This is particularly undesirable in virtualised
> > network environments.
> >=20
> > This patch introduces ethtool control of early orphaning.
> > It remains on by default by it now may be disabled on a per-interfa=
ce basis.
> >=20
> > I have implemented this as a generic flag.
> > As it seems to be the first generic flag that requires
> > no driver awareness I also supplied a default flag handler.
> > I am unsure if any aspect of this approach is acceptable.
> >=20
> > I believe Eric has it in mind that some of the calls
> > to skb_orphan() in drivers can be removed with the addition
> > of this feature. I need to discuss that with him further.
> >=20
> > A patch for the ethtool user-space utility accompanies this patch.
>=20
> The following results were measured using kvm using virto without vho=
st net.
> The virtio device is bridged to a bond device which has one gigabit s=
lave.
>=20

As you know, vhost net does the orphaning, as well as some NIC drivers,
so one UDP flood would have same problem.

I wonder if this problem could not be solved in other ways.


We might do early orphaning only for sockets with SOCK_USE_WRITE_QUEUE
flag asserted. (tcp sets it)

Then, we could also say : Why tcp use sock_wfree() at all...


Hmm...


