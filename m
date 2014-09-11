From: Daniel =?iso-8859-1?Q?Gl=F6ckner?= <dg@emlix.com>
Subject: Re: PTP_PEROUT_REQUEST and clock stepping
Date: Thu, 11 Sep 2014 11:52:45 +0200
Message-ID: <20140911095245.GA5823@emlix.com>
References: <54107965.6040007@emlix.com>
 <20140910172619.GB5944@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.emlix.com ([88.198.240.195]:60151 "EHLO mx1.emlix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752908AbaIKJws (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Sep 2014 05:52:48 -0400
Content-Disposition: inline
In-Reply-To: <20140910172619.GB5944@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 10, 2014 at 07:26:20PM +0200, Richard Cochran wrote:
> On Wed, Sep 10, 2014 at 06:16:37PM +0200, Daniel Gl=F6ckner wrote:
> > I was wondering how periodic output is supposed to behave if the cl=
ock
> > is stepped from a time after ptp_perout_request.start to a time bef=
ore
> > ptp_perout_request.start.
>=20
> I would say the result is undefined.
>=20
> User space should first stop the periodic output, then reprogram the
> clock, then restart the periodic output. Anything else makes no sense
> at all.

But then the PTP demon has to be responsible for configuring the period=
ic
outputs as well.

IMHO there is no use for a .start value > .period. It is good for defin=
ing
the phase of the periodic output but is just annoying if you want to ha=
ve
the periodic output running all the time. Only a small fraction of peop=
le
using periodic outputs will want to schedule the start of the signal at
a specific time in the future and only a fraction of those will use a
=2Eperiod value that is so small that they can't use a timer to configu=
re
the periodic output within .period/2 before the desired start time.

Best regards,

  Daniel

--=20
Dipl.-Math. Daniel Gl=F6ckner, emlix GmbH, http://www.emlix.com
=46on +49 551 30664-0, Fax +49 551 30664-11,
Bertha-von-Suttner-Stra=DFe 9, 37085 G=F6ttingen, Germany
Sitz der Gesellschaft: G=F6ttingen, Amtsgericht G=F6ttingen HR B 3160
Gesch=E4ftsf=FChrung: Dr. Uwe Kracke, Ust-IdNr.: DE 205 198 055

emlix - your embedded linux partner
