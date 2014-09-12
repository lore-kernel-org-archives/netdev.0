From: =?ISO-8859-1?Q?Daniel_Gl=F6ckner?= <dg@emlix.com>
Subject: Re: PTP_PEROUT_REQUEST and clock stepping
Date: Fri, 12 Sep 2014 13:40:32 +0200
Message-ID: <5412DBB0.9010008@emlix.com>
References: <54107965.6040007@emlix.com> <20140910172619.GB5944@localhost.localdomain> <20140911095245.GA5823@emlix.com> <CABkLOboeo_+37rE84gPTEKnmXD+599fRtnBZSR465y9aZeOdrw@mail.gmail.com> <20140912063310.GA6198@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>,
	Christian Riesch <christian.riesch@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.emlix.com ([88.198.240.195]:35858 "EHLO mx1.emlix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753893AbaILLkf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2014 07:40:35 -0400
In-Reply-To: <20140912063310.GA6198@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/12/14 08:33, Richard Cochran wrote:
> On Fri, Sep 12, 2014 at 08:24:49AM +0200, Christian Riesch wrote:
>> Ok, I got it now. So you are suggesting to change the behavior of
>> PTP_PEROUT_REQUEST, aren't you? And break existing applications?
>> Christian

I don't want to change the API. I would just have preferred a slightly
different one.

> I think he wants the periodic output to continue at the same phase an=
d
> frequency, even when you reset the clock time.
>=20
> However, this is impossible to acheive because the hardware does not
> support it.

You mean the hardware that you know of that currently exists.

I just think it is wrong to place the burden of stopping and starting
the periodic output on the PTP demon. The kernel knows when clock_adjti=
me
and clock_settime are called and it also knows which periodic outputs
are enabled and how they are configured. We just have to decide on the
correct behavior (respect .start vs. ignore .start once running) to be
implemented.

Taking the Intel i210 as an example, the third option (doing nothing)
would lead to the following behavior:

 - If the clock is stepped back, the periodic output stops until the
   clock reaches the point when it was adjusted.

 - If the clock is stepped forward, the periodic output oscillates at
   62,5 MHz to catch up.

Best regards,

  Daniel

--=20
Dipl.-Math. Daniel Gl=F6ckner, emlix GmbH, http://www.emlix.com
=46on +49 551 30664-0, Fax +49 551 30664-11,
Bertha-von-Suttner-Stra=DFe 9, 37085 G=F6ttingen, Germany
Sitz der Gesellschaft: G=F6ttingen, Amtsgericht G=F6ttingen HR B 3160
Gesch=E4ftsf=FChrer: Dr. Uwe Kracke, Ust-IdNr.: DE 205 198 055

emlix - your embedded linux partner
