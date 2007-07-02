From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Tue, 03 Jul 2007 00:12:50 +0200
Message-ID: <1183414370.4089.141.camel@johannes.berg>
References: <1179827251.7707.29.camel@localhost.localdomain>
	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>
	 <1181811576.5411.27.camel@localhost.localdomain>
	 <1181820510.4091.9.camel@localhost>
	 <1181869285.5411.39.camel@localhost.localdomain>
	 <1182178882.4063.11.camel@localhost>
	 <1182223964.5411.76.camel@localhost.localdomain>
	 <1182811210.6644.22.camel@johannes.berg>
	 <1182986681.5155.55.camel@localhost>
	 <1183121869.4089.57.camel@johannes.berg>  <468504FE.9000502@trash.net>
	 <1183122920.4089.63.camel@johannes.berg>  <468507C9.2000800@trash.net>
	 <1183124085.4089.66.camel@johannes.berg>  <46850CB8.8000509@trash.net>
	 <1183124981.4089.69.camel@johannes.berg>  <46850EDE.5020804@trash.net>
	 <1183125924.4089.73.camel@johannes.berg>
	 <1183126739.4089.76.camel@johannes.berg>
	 <1183129006.4089.84.camel@johannes.berg>
	 <1183217536.5165.25.camel@localhost>
	 <1183365821.4089.94.camel@johannes.berg>  <4688F612.1060408@trash.net>
	 <1183386883.4089.120.camel@johannes.ber g>  <46890DF8.2020706@trash.net>
	 <1183387687.4089.124.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-qmrMXRMUmAFkdwEUJj+8"
Cc: hadi@cyberus.ca, Zhang Rui <rui.zhang@intel.com>,
	netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:53759 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756300AbXGCLx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 07:53:28 -0400
In-Reply-To: <1183387687.4089.124.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-qmrMXRMUmAFkdwEUJj+8
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2007-07-02 at 16:48 +0200, Johannes Berg wrote:

> If I find time I might
> actually fix the unregistration bug too, but I have a feeling digging in
> the socket code might take more time than I have right now.

Hmm. I started digging into the af_netlink.c code and realised that the
whole thing I've been doing cannot possibly work completely since the
genl socket is created with GENL_MAX_ID as the "groups" parameter to
netlink_kernel_create() and that limits the groups, and the af_netlink
code really wants to know the number of groups up-front.

So some deeper surgery is required to lift the limit of 1023 multicast
group now. Not that I like the current genetlink code, we allocate 256
bytes for the in-kernel socket just for the listeners bitmap, and just
as many for each socket's groups bitmaps while it's unlikely a regular
system right now will ever reach that limit.

I'll be posting some patches as replies.

johannes

--=-qmrMXRMUmAFkdwEUJj+8
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD4DBQBGiXhi/ETPhpq3jKURAhfhAJ97jj0doWGvjGmJf1B0hzyiV7D9PwCYnVWv
HN7AdkR/X0ZoxxZQig16JA==
=c2cy
-----END PGP SIGNATURE-----

--=-qmrMXRMUmAFkdwEUJj+8--

