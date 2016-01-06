From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v2] net: Add eth_platform_get_mac_address() helper.
Date: Thu, 07 Jan 2016 00:41:29 +0100
Message-ID: <87r3hub7iu.fsf@nemi.mork.no>
References: <20160106.163309.111867454969344145.davem@davemloft.net>
	<1452121966.24575.52.camel@perches.com> <87vb76b87m.fsf@nemi.mork.no>
	<1452123144.24575.57.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	sowmini.varadhan@oracle.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:35907 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752192AbcAFXlj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 18:41:39 -0500
In-Reply-To: <1452123144.24575.57.camel@perches.com> (Joe Perches's message of
	"Wed, 06 Jan 2016 15:32:24 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches <joe@perches.com> writes:
> On Thu, 2016-01-07 at 00:26 +0100, Bj=C3=B8rn Mork wrote:
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
>> > > =C2=A0}
>> > > =C2=A0
>> > > =C2=A0fs_initcall(eth_offload_init);
>> > > +
>> > > +unsigned char * __weak arch_get_platform_mac_address(void)
>> > > +{
>> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0return NULL;
>> >=20
>> > WARN_ON_ONCE ?
>>=20
>> That would prevent a driver from using this with additional fallback
>> methods.=C2=A0=C2=A0For what reason?
>
> It's declared __weak and should be overridden by
> an arch specific function.

"should"?  Why?  Do you have a suggested implementation for - say - x86=
?

> A NULL address would cause a fault when using
> a function like copy_ether_addr.

You should not do that then :)


Bj=C3=B8rn
