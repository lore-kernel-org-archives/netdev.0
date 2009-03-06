From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ethtool: Support arbitrary speeds
Date: Fri, 06 Mar 2009 06:20:53 -0500
Message-ID: <49B10715.3050900@pobox.com>
References: <200901080203.SAA19103@tardy.cup.hp.com> <1231384446.2677.32.camel@hashbaz.i.decadent.org.uk> <49656F01.3090603@pobox.com>  <49664FFD.1010608@hp.com> <1231442701.3893.4.camel@achroite>  <496658EB.1080206@hp.com> <1231506974.3006.18.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40107 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754182AbZCFLVA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Mar 2009 06:21:00 -0500
In-Reply-To: <1231506974.3006.18.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> The speed and speed_hi fields of struct ethtool_cmd together represen=
t
> a value in units of Mbit/s.  The valid speed settings are hardware-
> dependent and should be checked by the driver.  Remove our validation
> and allow arbitrary positive values.  Continue to report 0 and -1 as
> "Unknown!" since some drivers will report these invalid values when
> the link is down.
>=20
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> On Thu, 2009-01-08 at 11:50 -0800, Rick Jones wrote:
>>> I think 0, (u32)(-1) and (u16)(-1) may have to be special-cased as
>>> unknown, but everything else can be treated as a number of Mbit/s. =
 I
>>> don't know what a driver should do about an interface that really r=
uns
>>> at 65.535 Gbit/s though...
>> Something along these lines then? (assuming my mailer doesn't fubar =
this
>> :( - I normally send matches via mailx)
>=20
> That's kind of incomplete.  Here's my attempt.
>=20
> In a quick test I found that the tg3 driver *doesn't* validate the sp=
eed
> setting if autonegotiation is off, and will accept and report back e.=
g.
> 99.  But this patch doesn't create a new problem as you could already
> set it to the unsupported speeds of 2500 and 10000.
>=20
> Ben.
> =EF=BB=BF
>  ethtool.8 |    4 ++--
>  ethtool.c |   42 ++++++++++--------------------------------
>  2 files changed, 12 insertions(+), 34 deletions(-)

ACK, can you rediff against current git repo?


