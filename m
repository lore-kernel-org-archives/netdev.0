From: =?ISO-8859-1?Q?Daniel_Gl=F6ckner?= <dg@emlix.com>
Subject: Re: PTP_PEROUT_REQUEST and clock stepping
Date: Fri, 12 Sep 2014 17:19:29 +0200
Message-ID: <54130F01.3080404@emlix.com>
References: <54107965.6040007@emlix.com> <20140910172619.GB5944@localhost.localdomain> <20140911095245.GA5823@emlix.com> <CABkLOboeo_+37rE84gPTEKnmXD+599fRtnBZSR465y9aZeOdrw@mail.gmail.com> <20140912063310.GA6198@netboy> <5412DBB0.9010008@emlix.com> <20140912144025.GA20712@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christian Riesch <christian.riesch@omicron.at>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.emlix.com ([88.198.240.195]:36246 "EHLO mx1.emlix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751283AbaILPTc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2014 11:19:32 -0400
In-Reply-To: <20140912144025.GA20712@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/12/14 16:40, Richard Cochran wrote:
>> Taking the Intel i210 as an example, the third option (doing nothing=
)
>> would lead to the following behavior:
>>
>>  - If the clock is stepped back, the periodic output stops until the
>>    clock reaches the point when it was adjusted.
>>
>>  - If the clock is stepped forward, the periodic output oscillates a=
t
>>    62,5 MHz to catch up.
>=20
> That is a good example of "the results are undefined".
>=20
> So, how would you reprogram the i210 to keep the period output
> continuous?

0. I'm assuming here that new_time >=3D start
1. stop the periodic output via TSAUXC
2. set the clock via SYSTIM* to new_time
3a. if (new_time - start) % period < period / 2
	set the TRGTTIM* regs to new_time - (new_time - start) % period
3b. else
	set the TRGTTIM* regs to new_time - (new_time - start) % period
	                                  + period
4. start the periodic output via TSAUXC

Best Regards,

  Daniel

--=20
Dipl.-Math. Daniel Gl=F6ckner, emlix GmbH, http://www.emlix.com
=46on +49 551 30664-0, Fax +49 551 30664-11,
Bertha-von-Suttner-Stra=DFe 9, 37085 G=F6ttingen, Germany
Sitz der Gesellschaft: G=F6ttingen, Amtsgericht G=F6ttingen HR B 3160
Gesch=E4ftsf=FChrer: Dr. Uwe Kracke, Ust-IdNr.: DE 205 198 055

emlix - your embedded linux partner
