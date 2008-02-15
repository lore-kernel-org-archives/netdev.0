From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: tbench regression in 2.6.25-rc1
Date: Fri, 15 Feb 2008 14:30:44 +0800
Message-ID: <1203057044.3027.134.camel@ymzhang>
References: <1203040321.3027.131.camel@ymzhang>
	 <47B52B95.3070607@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:36755 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750927AbYBOGeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 01:34:03 -0500
In-Reply-To: <47B52B95.3070607@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-02-15 at 07:05 +0100, Eric Dumazet wrote:
> Zhang, Yanmin a =E9crit :
> > Comparing with kernel 2.6.24, tbench result has regression with
> > 2.6.25-rc1.
> >=20
> > 1) On 2 quad-core processor stoakley: 4%.
> > 2) On 4 quad-core processor tigerton: more than 30%.
> >=20
> > bisect located below patch.
> >=20
> > b4ce92775c2e7ff9cf79cca4e0a19c8c5fd6287b is first bad commit
> > commit b4ce92775c2e7ff9cf79cca4e0a19c8c5fd6287b
> > Author: Herbert Xu <herbert@gondor.apana.org.au>
> > Date:   Tue Nov 13 21:33:32 2007 -0800
> >=20
> >     [IPV6]: Move nfheader_len into rt6_info
> >    =20
> >     The dst member nfheader_len is only used by IPv6.  It's also cu=
rrently
> >     creating a rather ugly alignment hole in struct dst.  Therefore=
 this patch
> >     moves it from there into struct rt6_info.
> >=20
> >=20
> > As tbench uses ipv4, so the patch's real impact on ipv4 is it delet=
es
> > nfheader_len in dst_entry. It might change cache line alignment.
> >=20
> > To verify my finding, I just added nfheader_len back to dst_entry i=
n 2.6.25-rc1
> > and reran tbench on the 2 machines. Performance could be recovered =
completely.
> >=20
> > I started cpu_number*2 tbench processes. On my 16-core tigerton:
> > #./tbench_srv &
> > #./tbench 32 127.0.0.1
> >=20
> > -yanmin
>=20
> Yup. struct dst is sensitive to alignements, especially for benches.
>=20
> In the real world, we need to make sure that next pointer start at a =
cache=20
> line bondary (or a litle bit after), so that RT cache lookups use one=
 cache=20
> line per entry instead of two. This permits better behavior in DDOS a=
ttacks.
>=20
> (check commit 1e19e02ca0c5e33ea73a25127dbe6c3b8fcaac4b for reference)
>=20
> Are you using a 64 or a 32 bit kernel ?
64bit x86-64 machine. On another 4-way Madison Itanium machine, tbench =
has the
similiar regression.

-yanmin


