From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ethtool.h: define DIV_ROUND_UP for userland
Date: Tue, 01 Mar 2016 14:48:26 -0500 (EST)
Message-ID: <20160301.144826.104748964516491333.davem@davemloft.net>
References: <1456845641-6985-1-git-send-email-nicolas.dichtel@6wind.com>
	<20160301.114232.138387157898713379.davem@davemloft.net>
	<1456852446.3098.157.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	nikolay@cumulusnetworks.com, kan.liang@intel.com
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40301 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752010AbcCATs3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 14:48:29 -0500
In-Reply-To: <1456852446.3098.157.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ben Hutchings <ben@decadent.org.uk>
Date: Tue, 01 Mar 2016 17:14:06 +0000

> On Tue, 2016-03-01 at 11:42 -0500, David Miller wrote:
>> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> Date: Tue,=A0 1 Mar 2016 16:20:41 +0100
>>=20
>> > DIV_ROUND_UP and is defined in linux/kernel.h only for the kernel.=
 INT_MAX
>> > needs limits.h in userland.
>>=20
>> It is wrong to provide a definition of this in the user visible glob=
al
>> namespace.
>=20
> Which is why he's not doing that...

No, that's exactly what he's doing:

+#ifndef __KERNEL__
+#include <limits.h> /* for INT_MAX */
+#define DIV_ROUND_UP(n, d) (((n) + (d) - 1) / (d))
+#endif

in a uapi header file.

"If not kernel, define DEV_ROUND_UP"
