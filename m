From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Multicast packet loss
Date: Mon, 02 Feb 2009 14:53:06 +0100
Message-ID: <4986FAC2.9030009@cosmosbay.com>
References: <49833DBC.7040607@athenacr.com> <20090130200330.GA12659@hmsreliant.think-freely.org> <49837F56.2020502@athenacr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Kenny Chang <kchang@athenacr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45666 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751188AbZBBNxP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2009 08:53:15 -0500
In-Reply-To: <49837F56.2020502@athenacr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kenny Chang a =E9crit :
> Ah, sorry, here's the test program attached.
>=20
> We've tried 2.6.28.1, but no, we haven't tried the 2.6.28.2 or the
> 2.6.29.-rcX.
>=20
> Right now, we are trying to step through the kernel versions until we
> see where the performance drops significantly.  We'll try 2.6.29-rc s=
oon
> and post the result.
>=20
> Neil Norman wrote:

On latest kernels, we have a "timer_slack_ns" default of 50.000 ns, aka=
 50us

So usleep(20) sleeps much more than expected.

You might add in your program a call to prcrl() to setup a smaller time=
r_slack :

#ifndef PR_SET_TIMERSLACK
#define PR_SET_TIMERSLACK 29
#endif
/*
 * Setup a timer resolution of 1000 ns : 1 us
 */
prctl(PR_SET_TIMERSLACK, 1000);=20




