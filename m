From: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>
Subject: Re: [PATCH] tcp: Increase the initial congestion window to 10.
Date: Thu, 3 Feb 2011 18:01:12 -0800
Message-ID: <AANLkTinkwzts5ysW26fHqX4u89Q=kW2kSOArqL=o6RLM@mail.gmail.com>
References: <20110202.170750.229739784.davem@davemloft.net>
	<alpine.DEB.2.00.1102040027060.25125@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, therbert@google.com,
	hkchu@google.com
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41047 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753877Ab1BDCBN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 21:01:13 -0500
Received: by wyb28 with SMTP id 28so1812877wyb.19
        for <netdev@vger.kernel.org>; Thu, 03 Feb 2011 18:01:12 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1102040027060.25125@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ilpo,

On Thu, Feb 3, 2011 at 2:43 PM, Ilpo J=E4rvinen <ilpo.jarvinen@helsinki=
=2Efi> wrote:
> It would perhaps be useful to change receiver advertized window to in=
clude
> some extra segs initially. It should be >=3D IW + peer's dupThresh-1 =
as
> otherwise limited transmit won't work for the initial window because =
we
> won't open more receiver window with dupacks (IIRC, I suppose Jerry m=
ight
> be able to correct me right away if I'm wrong and we open window with
> dupacks too?).

Sorry I don't know how the receive window is updated in Linux,
autotuning or not.
But I just wonder why would it have to do with dupacks, i.e., why would=
 it not
slide forward as long as the left edge of the window slides forward,
regardless of
OOO pkt arrival?

I am of the opinion that rwnd is for flow control purpose only thus sho=
uld be
fully decoupled from the cwnd of the other (sender) side. Therefore
initrwnd should
normally be based on projected BDP and local memory pressure, e.g., 64K=
B, not
bearing any relation with IW of the other side. Only under special
circumstances should it be used to constrain the sender, e.g., for
devices behind slow links with
very small buffer.

Jerry

>I think initial receiver window code used to have some
> surplus but it was broken by the rfc3390-func conversion (against my
> advice on how to do the conversion).
>
> --
> =A0i.
>
