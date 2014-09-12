From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: PTP_PEROUT_REQUEST and clock stepping
Date: Fri, 12 Sep 2014 16:40:25 +0200
Message-ID: <20140912144025.GA20712@netboy>
References: <54107965.6040007@emlix.com>
 <20140910172619.GB5944@localhost.localdomain>
 <20140911095245.GA5823@emlix.com>
 <CABkLOboeo_+37rE84gPTEKnmXD+599fRtnBZSR465y9aZeOdrw@mail.gmail.com>
 <20140912063310.GA6198@netboy>
 <5412DBB0.9010008@emlix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christian Riesch <christian.riesch@omicron.at>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Daniel =?iso-8859-1?Q?Gl=F6ckner?= <dg@emlix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:56002 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959AbaILOkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 10:40:39 -0400
Received: by mail-we0-f176.google.com with SMTP id q58so849753wes.7
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 07:40:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5412DBB0.9010008@emlix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 12, 2014 at 01:40:32PM +0200, Daniel Gl=F6ckner wrote:
> You mean the hardware that you know of that currently exists.

Yes, that is the hardware we support. I am sorry that I don't know how
to support mythical hardware.
=20
> I just think it is wrong to place the burden of stopping and starting
> the periodic output on the PTP demon.

I think it is the right place.

> The kernel knows when clock_adjtime
> and clock_settime are called and it also knows which periodic outputs
> are enabled and how they are configured. We just have to decide on th=
e
> correct behavior (respect .start vs. ignore .start once running) to b=
e
> implemented.

The only reasonable actions for kernel would be to either stop all
periodic outputs, or to just do nothing.
=20
> Taking the Intel i210 as an example, the third option (doing nothing)
> would lead to the following behavior:
>=20
>  - If the clock is stepped back, the periodic output stops until the
>    clock reaches the point when it was adjusted.
>=20
>  - If the clock is stepped forward, the periodic output oscillates at
>    62,5 MHz to catch up.

That is a good example of "the results are undefined".

So, how would you reprogram the i210 to keep the period output
continuous?

Thanks,
Richard
