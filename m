From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [Xen-devel] Re: [PATCH] xen network backend driver
Date: Wed, 19 Jan 2011 20:16:24 +0000
Message-ID: <1295468184.11126.72.camel@bwh-desktop>
References: <1295449318.14981.3484.camel@zakaz.uk.xensource.com>
	 <1295455216.11126.39.camel@bwh-desktop>
	 <1295459316.14981.3727.camel@zakaz.uk.xensource.com>
	 <1295460304.11126.53.camel@bwh-desktop> <4D3738AB.60701@goop.org>
	 <20110119192823.GN2754@reaktio.net> <1295466499.11126.67.camel@bwh-desktop>
	 <20110119195839.GO2754@reaktio.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	Ian Campbell <Ian.Campbell@eu.citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: Pasi =?ISO-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:11592 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533Ab1ASUQ2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 15:16:28 -0500
In-Reply-To: <20110119195839.GO2754@reaktio.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-01-19 at 21:58 +0200, Pasi K=C3=A4rkk=C3=A4inen wrote:
> On Wed, Jan 19, 2011 at 07:48:19PM +0000, Ben Hutchings wrote:
[...]
> > It was possible to use multiple receive queues per device long befo=
re
> > this since the networking core is not involved in locking them.  (T=
hough
> > it did require some hacks to create multiple NAPI contexts, before
> > 2.6.24.)  This is mostly useful useful in conjunction with separate=
 IRQs
> > per RX queue, spread across multiple CPUs (sometimes referred to as
> > Receive Side Scaling or RSS).
> >=20
>=20
> Ok. I should read changelogs more closely.. I thought both the receiv=
e/transmit=20
> multiqueue features appeared 'recently', but it seems I was wrong.

There was a relatively recent change that allows drivers to record whic=
h
receive queue each packet came in on.  This is used by RPS/RFS, and for
transmit queue selection when bridging/forwarding.  But multiple receiv=
e
queues were still usable before that.

> I think Linux 2.6.32 added multiqueue VLAN support..

VLAN devices and several other types of software device don't have
queues of their own, but they can now use all transmit queues of the
underlying device rather than just one.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

