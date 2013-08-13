From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCHv2 net-next] xfrm: Make xfrm_state timer monotonic
Date: Tue, 13 Aug 2013 12:59:16 +0200
Message-ID: <20130813105916.GC26773@secunet.com>
References: <1375772225-19265-1-git-send-email-fan.du@windriver.com>
 <20130806092220.GH25511@secunet.com>
 <52087537.6060200@windriver.com>
 <20130813075519.GN25511@secunet.com>
 <5209F030.3050303@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:48530 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756214Ab3HMK7T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Aug 2013 06:59:19 -0400
Content-Disposition: inline
In-Reply-To: <5209F030.3050303@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 13, 2013 at 04:37:04PM +0800, Fan Du wrote:
>=20
>=20
> On 2013=E5=B9=B408=E6=9C=8813=E6=97=A5 15:55, Steffen Klassert wrote:
> >On Mon, Aug 12, 2013 at 01:40:07PM +0800, Fan Du wrote:
> >>
> >>
> >>On 2013=E5=B9=B408=E6=9C=8806=E6=97=A5 17:22, Steffen Klassert wrot=
e:
> >>>On Tue, Aug 06, 2013 at 02:57:05PM +0800, Fan Du wrote:
> >>>>xfrm_state timer should be independent of system clock change,
> >>>>so switch to monotonic clock base.
> >>>>
> >>>
> >>>I think a monotonic timer will reintroduce a bug on suspend/resume
> >>>that was fixed by commit 9e0d57fd6
> >>>(xfrm: SAD entries do not expire correctly after suspend-resume)
> >>>
> >>>Please make sure that this does not happen.
> >>
> >>What about using CLOCK_BOOTTIME? it's monotonic, but includes suspe=
nd time as well.
> >
> >As I said, I'm open to everything that fixes your problem and does n=
ot
> >introduce a regression. I'll consider applying after some testing
> >if noone else has objections.
>=20
> Hi, Steffen
>=20
> Thanks for your understanding! :)
>=20
> I happened to bump into CLOCK_BOOTTIME several days ago, so apologize=
 for
> eating my words earlier. Changing xfrm_state timer to monotonic does =
not
> solve the problem I've described earlier in:
>=20
> http://www.spinics.net/lists/netdev/msg245019.html (*1*)
>=20
> So is there any light of hope for the proposal in (*1*) by using CLOC=
K_BOOTTIME
> instead?
>=20

Well, you have to convince David in the first place, as he is sitting
upstream from me ;)

Also, I think he is right with his complaint. Why not following the
clock_was_set approach you started with?
