From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] net: Add eth_platform_get_mac_address() helper.
Date: Wed, 06 Jan 2016 15:32:24 -0800
Message-ID: <1452123144.24575.57.camel@perches.com>
References: <20160106.163309.111867454969344145.davem@davemloft.net>
	 <1452121966.24575.52.camel@perches.com> <87vb76b87m.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	sowmini.varadhan@oracle.com
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0145.hostedemail.com ([216.40.44.145]:58074 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751966AbcAFXc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 18:32:27 -0500
In-Reply-To: <87vb76b87m.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-01-07 at 00:26 +0100, Bj=F8rn Mork wrote:
> Joe Perches <joe@perches.com> writes:
> > On Wed, 2016-01-06 at 16:33 -0500, David Miller wrote:
> > > A repeating pattern in drivers has become to use OF node informat=
ion
> > > and, if not found, platform specific host information to extract =
the
> > > ethernet address for a given device.
> > []
> > > diff --git a/include/linux/etherdevice.h b/include/linux/etherdev=
ice.h
> > []
> > > @@ -485,3 +487,32 @@ static int __init eth_offload_init(void)
> > > =A0}
> > > =A0
> > > =A0fs_initcall(eth_offload_init);
> > > +
> > > +unsigned char * __weak arch_get_platform_mac_address(void)
> > > +{
> > > +=A0=A0=A0=A0=A0=A0=A0return NULL;
> >=20
> > WARN_ON_ONCE ?
>=20
> That would prevent a driver from using this with additional fallback
> methods.=A0=A0For what reason?

It's declared __weak and should be overridden by
an arch specific function.

A NULL address would cause a fault when using
a function like copy_ether_addr.


> I don't have a specific usecase, but I can imagine drivers falling ba=
ck
> to e.g a random address without wanting to be noisy about it.
