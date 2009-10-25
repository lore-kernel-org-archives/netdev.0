From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC] make per interface sysctl entries configurable
Date: Mon, 26 Oct 2009 00:21:48 +0200
Message-ID: <200910260021.48785.opurdila@ixiacom.com>
References: <200910251954.49700.opurdila@ixiacom.com> <4AE4C50F.7060605@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Benjamin LaHaise <bcrl@lhnet.ca>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cosmin Ratiu <cratiu@ixiacom.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:32931 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754262AbZJYWYl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2009 18:24:41 -0400
In-Reply-To: <4AE4C50F.7060605@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 25 October 2009 23:37:19 you wrote:
> Octavian Purdila a =E9crit :
> > RFC patches are attached.
> >
> > Another possible approach: add an interface flag and use it to deci=
de
> > whether we want per interface sysctl entries or not.
>=20
> Hmm, could we speedup sysctl instead, adding rbtree or something ?
>=20

Very good point, I think this is the best solution for people using a=20
moderately high number of interfaces (a few thousand).

But for really large setups there is another issue: memory consumption.=
 In=20
fact, in order to be able to scale to 128K interfaces and still have a=20
significant amount of memory available to applications we also had to d=
isable=20
sysfs and #ifdef CONFIG_SYSFS struct device from net_device.

I would also argue that when you have such a large number of interfaces=
 you=20
don't need to change setting on a per interface basis. Or at least this=
 is our=20
case :)  and I suspect that the case with a large number of PPP interfa=
ces is=20
similar.
