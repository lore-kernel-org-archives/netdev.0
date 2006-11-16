From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch 1/2]d80211: hardware TKIP support for ipw3945
Date: Thu, 16 Nov 2006 18:38:20 +0100
Message-ID: <1163698700.3392.7.camel@johannes.berg>
References: <20061023145646.32bbd59f@griffin.suse.cz>
	 <1161678053.7083.7.camel@devlinux-hong> <1161678908.2840.12.camel@ux156>
	 <1161679134.7258.6.camel@devlinux-hong> <1161681021.2840.23.camel@ux156>
	 <1161764889.8668.13.camel@devlinux-hong> <1161766245.2767.17.camel@ux156>
	 <1163470978.7789.31.camel@devlinux-hong> <1163607901.2705.53.camel@ux156>
	 <1163670762.2763.19.camel@ux156>  <20061116172131.GA7404@instant802.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-5MGNZzLRA3qsh/0Po47Q"
Cc: Hong Liu <hong.liu@intel.com>, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>, Michael Buesch <mb@bu3sch.de>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Simon Barber <simon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:42372 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1162056AbWKPRkI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 12:40:08 -0500
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20061116172131.GA7404@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-5MGNZzLRA3qsh/0Po47Q
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2006-11-16 at 09:21 -0800, Jouni Malinen wrote:

> Hmm.. I think I need to see the patch for doing this before being able
> to decide whether I'd like this or not.. Michael MIC is a bit
> unfortunate design since it happens at MSDU, not MPDU level. Because of
> this, most hardware designs have to do something special when
> fragmentation is used. If the fragmentation is done in the stack, it may
> be difficult to move the Michael MIC operations into the driver since
> they need to happen before fragmentation (which would be done in the
> stack in this case)..

Oh, good point. Will need to think about this more. But right now, if
that MMIC flag is set (i.e. hw does MMIC), we still do MMIC for
fragmented frames. And there's actually a bug here I think: if hw does
MMIC, how can the driver tell not to do it on those frames it's getting
as fragments?

> Other than this special case, it sounds reasonable to keep most of the
> small hardware design changes hidden in the driver code as long as the
> functions that are exported from the stack are the same ones that the
> stack would be using anyway (i.e., not having to maintain two versions
> of the same code).

Of course, for this TKIP stuff I'd only export those functions the
drivers will need and remove the flags, for software crypto (in stack)
they'd still be used as-is.

johannes

--=-5MGNZzLRA3qsh/0Po47Q
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARVyiC6Vg1VMiehFYAQJMHw/+K0yGGA/5pYRZj7NLuJklNvEgEXJjpNvY
bL5VHIj1VxFvSXjMOpEWDT7KQSjLqEEqBBhDCDr5w7QLg4VRg0c/DKoJnAIKL76C
fac2Onke0Qqfk2Z3VImunXAMmuZNAFVHPlN5hWEhRjxXQ8lE8lX7Cm9TRExZ4alu
97Ani524Rn8pHVQJhrkrVGXOJF78htVU6IGSkL9iRhZMmCym8CNHezrSIh77ufb5
JvGB26P/adODwclGjSr6FxKEFv/jMLh89bdSMuCiNpyQTxH32XNpbt8R2zNhvGuS
9Mp8cQrRV8UD3xQ2K2yT1cykAYI9h6JSI9Kx8Z4m27U1JBjTgFlOLP3D4p+Gtpv7
7B2ZSk5M/MR9W+lccj2xIVMX4RTLmzuKFsIy7PiX+OxxvafXnI+qGWAsmd6ms+OT
RttNKVCUf8PO3qg30ukNAFlRSO6qCXz8+a5a3VSMU2h4gRJqSyF6mASw1Qb6uPIp
FKOWrK97Lxc/+GqdzQGMhKr/S3mD5YfTh9A0FRY0AiS5GO2Nrye17QHxRYopv/7L
k8rqIaTzBeS4g5cb5wyT+Sbh5vFbWejnwtHD8BmVEwqi6qRGIs7WPwHgKb9m7D2E
U1hqoJu0GCj0XmsjqyAOeRk3Sf6JOPP6FT9mz6TdNH6lty5eIMkp+lb8UE81xNdg
6rKgy2pHYcU=
=3PyB
-----END PGP SIGNATURE-----

--=-5MGNZzLRA3qsh/0Po47Q--

