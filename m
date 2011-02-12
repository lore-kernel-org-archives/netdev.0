From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 3/4] bond: implement slave management
 operations
Date: Sat, 12 Feb 2011 14:20:42 +0100
Message-ID: <20110212132040.GA12156@psychotron.redhat.com>
References: <20110211152125.GA2763@psychotron.brq.redhat.com>
 <20110211152257.GC2763@psychotron.brq.redhat.com>
 <4D568822.3010402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22653 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751989Ab1BLNUt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Feb 2011 08:20:49 -0500
Content-Disposition: inline
In-Reply-To: <4D568822.3010402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Feb 12, 2011 at 02:16:18PM CET, nicolas.2p.debian@gmail.com wrote:
>Le 11/02/2011 16:22, Jiri Pirko a =E9crit :
>>
>>Signed-off-by: Jiri Pirko<jpirko@redhat.com>
>>---
>>  drivers/net/bonding/bond_main.c |   38 ++++++++++++++++++++++++++++=
++++++++++
>>  1 files changed, 38 insertions(+), 0 deletions(-)
>>
>>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
>>index 1df9f0e..f8e59f9 100644
>>--- a/drivers/net/bonding/bond_main.c
>>+++ b/drivers/net/bonding/bond_main.c
>>@@ -4285,6 +4285,40 @@ unwind:
>>  	return res;
>>  }
>>
>>+static int bond_add_slave(struct net_device *bond_dev,
>>+			  struct net_device *slave_dev)
>>+{
>>+	return bond_enslave(bond_dev, slave_dev);
>>+}
>>+
>>+static int bond_del_slave(struct net_device *bond_dev,
>>+			  struct net_device *slave_dev)
>>+{
>>+	return bond_release(bond_dev, slave_dev);
>>+}
>>+
>
>Hi Jiri,
>
>Why did you add another level of function nesting (bond_add_slave()
>and bond_del_slave()) instead of using bond_enslave() and
>bond_release() directly in the structure below ?
>
>The function prototypes are identical.
>
>Or may be, rename bond_enslave() to bond_add_slave() and
>bond_release() to bond_del_slave(), for consistency.

Yes you are right - I did it in bonding by copy & paste code I did in
bridge and I didn't see that here it isn't necessary... Will remake thi=
s
in respin patchset.

Thanks.

Jirka
>
>>+	.ndo_add_slave		=3D bond_add_slave,
>>+	.ndo_del_slave		=3D bond_del_slave,
>>+	.ndo_get_slave_count	=3D bond_get_slave_count,
>>+	.ndo_get_slave		=3D bond_get_slave,
>
>	Nicolas.
