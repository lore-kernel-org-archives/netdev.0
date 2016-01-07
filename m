From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: Add eth_platform_get_mac_address() helper.
Date: Wed, 06 Jan 2016 19:01:07 -0500 (EST)
Message-ID: <20160106.190107.1969093816791419629.davem@davemloft.net>
References: <1452121966.24575.52.camel@perches.com>
	<87vb76b87m.fsf@nemi.mork.no>
	<1452123144.24575.57.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bjorn@mork.no, netdev@vger.kernel.org, sowmini.varadhan@oracle.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41356 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752794AbcAGABQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 19:01:16 -0500
In-Reply-To: <1452123144.24575.57.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Joe Perches <joe@perches.com>
Date: Wed, 06 Jan 2016 15:32:24 -0800

> On Thu, 2016-01-07 at 00:26 +0100, Bj=F8rn Mork wrote:
>> Joe Perches <joe@perches.com> writes:
>> > On Wed, 2016-01-06 at 16:33 -0500, David Miller wrote:
>> > > A repeating pattern in drivers has become to use OF node informa=
tion
>> > > and, if not found, platform specific host information to extract=
 the
>> > > ethernet address for a given device.
>> > []
>> > > diff --git a/include/linux/etherdevice.h b/include/linux/etherde=
vice.h
>> > []
>> > > @@ -485,3 +487,32 @@ static int __init eth_offload_init(void)
>> > > =A0}
>> > > =A0
>> > > =A0fs_initcall(eth_offload_init);
>> > > +
>> > > +unsigned char * __weak arch_get_platform_mac_address(void)
>> > > +{
>> > > +=A0=A0=A0=A0=A0=A0=A0return NULL;
>> >=20
>> > WARN_ON_ONCE ?
>>=20
>> That would prevent a driver from using this with additional fallback
>> methods.=A0=A0For what reason?
>=20
> It's declared __weak and should be overridden by
> an arch specific function.
>=20
> A NULL address would cause a fault when using
> a function like copy_ether_addr.

The caller checks for NULL, and this is the default implementation
doing precisely what it is meant to do.
