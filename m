From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [RFC PATCH 03/13] xen-netback: implement TX persistent grants
Date: Sun, 7 Jun 2015 13:04:23 +0100
Message-ID: <20150607120423.GV29102@zion.uk.xensource.com>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
 <1431451117-70051-4-git-send-email-joao.martins@neclab.eu>
 <20150519152342.GB26335@zion.uk.xensource.com>
 <30CF0FF9-3B1D-48AF-AFB4-73E20C404357@neclab.eu>
 <20150602145359.GP19403@zion.uk.xensource.com>
 <B1B43019-3C94-4FBA-9139-7683FEC2901E@neclab.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wei Liu <wei.liu2@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ian.campbell@citrix.com" <ian.campbell@citrix.com>,
	"david.vrabel@citrix.com" <david.vrabel@citrix.com>,
	"boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Joao Martins <Joao.Martins@neclab.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:65033 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752670AbbFGME0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2015 08:04:26 -0400
Content-Disposition: inline
In-Reply-To: <B1B43019-3C94-4FBA-9139-7683FEC2901E@neclab.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 03, 2015 at 05:07:59PM +0000, Joao Martins wrote:
[...]
> >=20
> > How much harder would it be to ref-count inflight grants? Would tha=
t
> > simplify or perplex things? I'm just asking, not suggesting you sho=
uld
> > choose ref-counting over current scheme.
> >=20
> > In principle I favour simple code path over optimisation for every
> > possible corner case.
>=20
> ref-counting the persistent grants would mean eliminating the check f=
or
> EBUSY on xenvif_pgrant_new, but though it isn=E2=80=99t that much of =
a simplification.
>=20

Right.

> What would simplify a lot is if I grant map when we don=E2=80=99t get=
 a persistent_gnt
> in xenvif_pgrant_new() and add it to the tree there instead of doing =
on xenvif_tx_check_gop.
> Since this happens only once for persistent grants (and up to ring si=
ze), I believe it
> wouldn't hurt performance.
>=20

Yeah. Mapping page inside xenvif_tx_check_gop doesn't sound nice.

> This way we would remove a lot of the checks in xenvif_tx_check_gop a=
nd
> hopefully leaving those parts (almost) intact mainly to be used for g=
rant
> map/unmap case. The reason I didn=E2=80=99t do it because I wanted to=
 reuse the
> grant map code and thought that preference was given towards batching=
 the
> grant maps. But it looks that it definitely makes things more complic=
ated
> and adds more corner cases.
>=20
> The same goes for the RX case where this change would remove a lot of=
 the code
> for adding the grant maps (thus sharing a lot from the TX part) besid=
es removing the
> mixed initial grant copy + map. What do you think?
>=20

I couldn't really comment until I see the code. But in principle I thin=
k
this is a step towards the right direction.

Wei.

> Joao
