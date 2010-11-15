From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Mon, 15 Nov 2010 17:58:09 +0100
Message-ID: <1289840289.2607.92.camel@edumazet-laptop>
References: <20101115114651.8e6bad6c.sfr@canb.auug.org.au>
	 <20101115.085254.104057401.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101115.085254.104057401.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 15 novembre 2010 =C3=A0 08:52 -0800, David Miller a =C3=A9crit=
 :
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Mon, 15 Nov 2010 11:46:51 +1100
>=20
> > Caused by commit 1d7138de878d1d4210727c1200193e69596f93b3 ("igmp: R=
CU
> > conversion of in_dev->mc_list").  The for_each_pmc_rtnl and
> > for_each_pmc_rcu definitions are protected by  CONFIG_IP_MULTICAST,=
 but
> > the uses are not ...
>=20
> Thanks for the report, I've pushed the following fix:
>=20
> --------------------
> ipv4: Fix build with multicast disabled.
>=20
> net/ipv4/igmp.c: In function 'ip_mc_inc_group':
> net/ipv4/igmp.c:1228: error: implicit declaration of function 'for_ea=
ch_pmc_rtnl'
> net/ipv4/igmp.c:1228: error: expected ';' before '{' token
> net/ipv4/igmp.c: In function 'ip_mc_unmap':
> net/ipv4/igmp.c:1333: error: expected ';' before 'igmp_group_dropped'
>  ...
>=20
> Move for_each_pmc_rcu and for_each_pmc_rtnl macro definitions
> outside of multicast ifdef protection.
>=20
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
> =20

Oops thats right, sorry David, I missed this message.
