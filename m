From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Optics (SFP) monitoring on ixgbe and igbe
Date: Wed, 7 Nov 2012 19:58:59 +0000
Message-ID: <1352318339.2725.34.camel@bwh-desktop.uk.solarflarecom.com>
References: <CAPN4dA8WUdox2k_F_9cYw=hR=xZHia=z3CXwy-36_t9Hh58zBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: <footplus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:42313 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751736Ab2KGT7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 14:59:03 -0500
In-Reply-To: <CAPN4dA8WUdox2k_F_9cYw=hR=xZHia=z3CXwy-36_t9Hh58zBg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-07 at 13:27 +0100, Aur=C3=A9lien wrote:
> Hello,
>=20
> I'm looking to propose a patch for optics monitoring on igbe and ixgb=
e
> cards which support SFP and SFP+. I have one of each card. While
> searching for previous work done by others on this domain, i found th=
e
> following:
>=20
> https://github.com/jelaas/bifrost-build-x86_64/tree/master/all/kernel=
-x86_64-3.3.0-rc2-1
> (the DOM-* files)
>=20
> I did not yet test this patch (i'll do in a few days), but just by
> looking at the patches, do you think this could get incorporated in
> the current state, provided some administrative work is done, or woul=
d
> it require more architectural rework / documentation / other ?
>=20
> Could you point me to the next steps required for the functionality t=
o
> be merged in a future mainline kernel/ethtool ? Is there a better
> place than netdev@ to discuss this matter ?

We just added the ETHTOOL_GMODULEINFO and ETHTOOL_GMODULEEEPROM
interface for this purpose.  The diagnostics obviously aren't really an
EEPROM but I don't think that matters.

These drivers should report a type of ETH_MODULE_SFF_8472 (assuming a
module is present) and expose an 'EEPROM' with the real EEPROM in the
first 256 bytes and the diagnostic registers in the next 256 bytes.

Decoding of the diagnostic registers can be done in ethtool itself.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
