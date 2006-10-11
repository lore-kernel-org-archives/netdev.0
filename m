From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 21/21]: powerpc/cell spidernet DMA coalescing
Date: Wed, 11 Oct 2006 11:25:09 +0200
Message-ID: <200610111125.10902.arnd@arndb.de>
References: <20061010204946.GW4381@austin.ibm.com> <452C2AAA.5070001@austin.ibm.com> <452C4CE0.5010607@am.sony.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jschopp <jschopp@austin.ibm.com>,
	Linas Vepstas <linas@austin.ibm.com>, akpm@osdl.org,
	jeff@garzik.org, netdev@vger.kernel.org,
	James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.183]:54776 "EHLO
	moutng.kundenserver.de") by vger.kernel.org with ESMTP
	id S1750785AbWJKJZb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2006 05:25:31 -0400
To: Geoff Levand <geoffrey.levand@am.sony.com>
In-Reply-To: <452C4CE0.5010607@am.sony.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 11 October 2006 03:46, Geoff Levand wrote:
> >=20
> > The others look good, but this one complicates the code and doesn't=
 have any benefit. =C2=A020=20
> > for 21 isn't bad.
>=20
> Is the motivation for this change to improve performance by reducing =
the overhead
> of the mapping calls? =C2=A0If so, there may be some benefit for some=
 systems. =C2=A0Could
> you please elaborate?
>=20

=46rom what I understand, this patch drastically reduces the number of
I/O PTEs that are needed in the iommu. With the current static IOMMU
mapping, it should only make a difference during initialization, but
any platform that uses a dynamic mapping of iommu entries will benefit
a lot from it, because:

- the card can do better prefetching of consecutive memory
- there are more I/O ptes available for other drivers.

	Arnd <><
