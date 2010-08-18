From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] ehea: Allocate stats buffer with GFP_KERNEL
Date: Wed, 18 Aug 2010 16:10:52 +0200
Message-ID: <1282140652.2194.90.camel@edumazet-laptop>
References: <201006302159.o5ULx8ow025348@d01av03.pok.ibm.com>
	 <20100701.224805.221588889.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: brking@linux.vnet.ibm.com, ossthema@de.ibm.com,
	osstklei@de.ibm.com, raisch@de.ibm.com, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63840 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753383Ab0HROLF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 10:11:05 -0400
Received: by wwi17 with SMTP id 17so882329wwi.1
        for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 07:11:03 -0700 (PDT)
In-Reply-To: <20100701.224805.221588889.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 01 juillet 2010 =C3=A0 22:48 -0700, David Miller a =C3=A9crit =
:
> From: Brian King <brking@linux.vnet.ibm.com>
> Date: Wed, 30 Jun 2010 16:59:12 -0500
>=20
> >=20
> > Since ehea_get_stats calls ehea_h_query_ehea_port, which
> > can sleep, we can also sleep when allocating a page in
> > this function. This fixes some memory allocation failure
> > warnings seen under low memory conditions.
> >=20
> > Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
>=20
> Applied to net-next-2.6
> --

I believe there is a problem with this patch and/or bonding.

If we say ndo_get_stats() methods are allowed to sleep, then=20
bond_get_stats() should be updated, because it currently calls
dev_get_stats() from a read_lock_bh(&bond->lock); section.

Are we allowed to sleep inside a read_lock_bh() ?



