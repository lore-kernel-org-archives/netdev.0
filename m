From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: why all packets have same queue no when rps enabled?
Date: Tue, 22 Feb 2011 14:01:58 +0100
Message-ID: <1298379718.2861.3.camel@edumazet-laptop>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F24D3DE6D0C@MILEXCH2.ds.jdsu.net>
	 <1298378756.2211.478.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jon Zhou <Jon.Zhou@jdsu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:47282 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736Ab1BVNC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 08:02:28 -0500
Received: by fxm17 with SMTP id 17so2714073fxm.19
        for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 05:02:27 -0800 (PST)
In-Reply-To: <1298378756.2211.478.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 22 f=C3=A9vrier 2011 =C3=A0 12:45 +0000, Ben Hutchings a =C3=A9=
crit :

> The queue number identifies a hardware queue.  RPS therefore does not
> update this number when queueing packets for processing on other CPUs=
=2E
>=20
> If the hardware/driver provides a receive hash (probably Toeplitz) th=
en
> this is used for RPS.  Otherwise a much cheaper hash is used.

The default is/should be : rxhash generated in network stack.

ethtool -k eth0 | grep hash
receive-hashing: off

To use the device/harwdare provided rxhash, you need to ask for it.

ethtool -K eth0 rxhash on



BTW, I am not sure what you mean by "much cheaper hash is used"...

I presume hardware provided hash is less expensive (for our cpu) than
computing our rxhash...



