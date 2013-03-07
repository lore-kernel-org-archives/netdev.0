From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] net/rds: using strlcpy instead of strncpy
Date: Thu, 07 Mar 2013 12:03:27 +0800
Message-ID: <5138118F.606@asianux.com>
References: <512F1534.9020404@asianux.com>     <AE90C24D6B3A694183C094C60CF0A2F6026B716D@saturn3.aculab.com>     <1362421944.2956.15.camel@bwh-desktop.uk.solarflarecom.com>    <1362422090.2956.18.camel@bwh-desktop.uk.solarflarecom.com>    <51355936.3060307@asianux.com>   <1362453419.3768.380.camel@deadeye.wl.decadent.org.uk>   <51356735.4020405@asianux.com>  <1362454672.3768.383.camel@deadeye.wl.decadent.org.uk>  <51356FED.4070909@asianux.com> <1362502844.2791.32.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Laight <David.Laight@ACULAB.COM>,
	venkat.x.venkatsubra@oracle.com,
	David Miller <davem@davemloft.net>, rds-devel@oss.oracle.com,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:12591 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754335Ab3CGEDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 23:03:52 -0500
In-Reply-To: <1362502844.2791.32.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B403=E6=9C=8806=E6=97=A5 01:00, Ben Hutchings =E5=86=
=99=E9=81=93:
> This function calls rds_copy_info() to copy the whole of ctr into
> userland.
>=20
> If ctr is not completely initialised, then the values of the
> uninitialised bytes are left over from the local variables of an earl=
ier
> system call.  If an attacker knows enough about the stack layout (eas=
y
> if this is a distribution kernel), they can make a series of system
> calls that leak information about heap-allocated objects.  That can h=
elp
> them to exploit other kernel bugs for privilege escalation.  So we
> should initialise every bit of memory that is going to be copied to
> userland.
>=20
> (In fact, in general it's not even enough to initialise all fields of
> the structure, because there may be padding bytes between them.  In t=
his
> case we know there isn't, because it's declared as packed.)
>=20
> Ben.

  thank you for your information.

  I should send patch v2 for it.

  :-)


--=20
Chen Gang

Asianux Corporation
