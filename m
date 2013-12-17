From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next] xfrm: Namespacify xfrm_policy_sk_bundles
Date: Tue, 17 Dec 2013 12:39:50 +0100
Message-ID: <20131217113950.GL31491@secunet.com>
References: <1387189568-31769-1-git-send-email-fan.du@windriver.com>
 <20131216122325.GI31491@secunet.com>
 <52AFACCA.20107@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:60734 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751072Ab3LQLjw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Dec 2013 06:39:52 -0500
Content-Disposition: inline
In-Reply-To: <52AFACCA.20107@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 17, 2013 at 09:45:46AM +0800, Fan Du wrote:
>=20
>=20
> On 2013=E5=B9=B412=E6=9C=8816=E6=97=A5 20:23, Steffen Klassert wrote:
> >On Mon, Dec 16, 2013 at 06:26:08PM +0800, Fan Du wrote:
> >>
> >>And also since xfrm_policy_sk_bundles is only used in xfrm_lookup a=
nd
> >>__xfrm_garbage_collect, both in process context, no reason we shoul=
d turn
> >>BH off.
> >
> >Are you sure about that?
> >
> >__xfrm_garbage_collect() is called via dst_alloc() which can be call=
ed
> >from softirq and process context.
>=20
> Thanks for pointing this out, you are correct! :)
>=20
> IMO, xchg can still cover those two cases:
> 1. xfrm_lookup(Process context)  vs  __xfrm_garbage_collect(softirq c=
ontext)
> 2. xfrm_lookup(Process context)  vs  __xfrm_garbage_collect(Process c=
ontext when SPD change or dev down)
>=20
> I will fix commit message properly on v2 if you are ok with above des=
cription.

Yes, please fix and resend.
