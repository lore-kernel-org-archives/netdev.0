From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2] sctp: Change defaults on cookie hmac selection
Date: Mon, 7 Jan 2013 09:49:21 -0500
Message-ID: <20130107144921.GA31577@hmsreliant.think-freely.org>
References: <1355511060-27320-1-git-send-email-nhorman@tuxdriver.com>
 <1355534521-32719-1-git-send-email-nhorman@tuxdriver.com>
 <50EACCD3.90609@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34855 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750969Ab3AGOtc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 09:49:32 -0500
Content-Disposition: inline
In-Reply-To: <50EACCD3.90609@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 07, 2013 at 02:25:39PM +0100, Florian Fainelli wrote:
> Hello Neil,
>=20
> Le 12/15/12 02:22, Neil Horman a =E9crit :
> >Recently I posted commit 3c68198e75 which made selection of the cook=
ie hmac
> >algorithm selectable.  This is all well and good, but Linus noted th=
at it
> >changes the default config:
> >http://marc.info/?l=3Dlinux-netdev&m=3D135536629004808&w=3D2
> >
> >I've modified the sctp Kconfig file to reflect the recommended way o=
f making
> >this choice, using the thermal driver example specified, and brought=
 the
> >defaults back into line with the way they were prior to my origional=
 patch
> >
> >Also, on Linus' suggestion, re-adding ability to select default 'non=
e' hmac
> >algorithm, so we don't needlessly bloat the kernel by forcing a non-=
none
> >default.  This also led me to note that we won't honor the default n=
one
> >condition properly because of how sctp_net_init is encoded.  Fix tha=
t up as
> >well.
> >
> >Tested by myself (allbeit fairly quickly).  All configuration combin=
ations seems
> >to work soundly.
> >
> >Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> >CC: David Miller <davem@davemloft.net>
> >CC: Linus Torvalds <torvalds@linux-foundation.org>
> >CC: Vlad Yasevich <vyasevich@gmail.com>
> >CC: linux-sctp@vger.kernel.org
> >---
> >  net/sctp/Kconfig    | 27 +++++++++++++++++++++++++--
> >  net/sctp/protocol.c |  4 ++--
> >  2 files changed, 27 insertions(+), 4 deletions(-)
> >
> >diff --git a/net/sctp/Kconfig b/net/sctp/Kconfig
> >index a9edd2e..c262106 100644
> >--- a/net/sctp/Kconfig
> >+++ b/net/sctp/Kconfig
> >@@ -66,12 +66,36 @@ config SCTP_DBG_OBJCNT
> >  	  'cat /proc/net/sctp/sctp_dbg_objcnt'
> >
> >  	  If unsure, say N
> >+choice
> >+	prompt "Default SCTP cookie HMAC encoding"
> >+	default SCTP_COOKIE_HMAC_MD5
>=20
> Should not this be SCTP_DEFAULT_COOKIE_HMAC_MD5? I just tried to
> update to 3.8-rc2, and I usually build my kernel-headers with:
>=20
> yes '' | ARCH=3Dfoo make oldconfig
>=20
> and this just kept asking me for this config symbol because none
> could be provided.
> --
> Florian
>=20

No, the config mechanism is setup to offer the user the ability to choo=
se a
default cookie hmac, alg, then optionally select any other hmac algs yo=
u would
like to be made available (in the event you want to change the default =
at run
time).  When you select the default, it eables (via the select directiv=
e), the
corresponding SCTP_COOKIE_HMAC_* config option, which is used in the bu=
ild, and
then prompts for the remaining values.

Neil
