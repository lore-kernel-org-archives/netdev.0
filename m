From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH/RFC] make unregister_netdev() delete more than 4 interfaces
 per second
Date: Sun, 18 Oct 2009 21:36:00 +0200
Message-ID: <4ADB6E20.4000508@gmail.com>
References: <20091017221857.GG1925@kvack.org> <4ADA98EE.9040509@gmail.com> <20091018161356.GA23395@kvack.org> <4ADB55BC.5020107@gmail.com> <20091018182144.GC23395@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@lhnet.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42374 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755058AbZJRTgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 15:36:06 -0400
In-Reply-To: <20091018182144.GC23395@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin LaHaise a =E9crit :
>=20
> My goal is tearing down 100,000 interfaces in a few seconds, which re=
ally is=20
> necessary.  Right now we're running about 40,000 interfaces on a not =
yet=20
> saturated 10Gbps link.  Going to dual 10Gbps links means pushing more=
 than=20
> 100,000 subscriber interfaces, and it looks like a modern dual socket=
 system=20
> can handle that.
>=20
> A bigger concern is rtnl_lock().  It is a huge impediment to scaling =
up=20
> interface creation/deletion on multicore systems.  That's going to be=
 a=20
> lot more invasive to fix, though.

Dont forget synchronize_net() too (two calls per rollback_registered())

You need something to dismantle XXXXX interfaces at once, instead
of serializing one by one. Because in three years you'll want to disman=
tle
1.000.000 interfaces in one second.

Maybe defining an asynchronous unregister_netdev() function...



