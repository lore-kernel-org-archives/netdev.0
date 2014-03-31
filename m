From: "zheng.li" <zheng.x.li@oracle.com>
Subject: Re: [PATCH] bonding: Inactive slaves should keep inactive flag's
 value to 1
Date: Mon, 31 Mar 2014 14:58:26 +0800
Message-ID: <53391212.70205@oracle.com>
References: <1395998529-5937-1-git-send-email-zheng.x.li@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Zheng Li <zheng.x.li@oracle.com>, netdev@vger.kernel.org,
	andy@greyhouse.net, linux-kernel@vger.kernel.org,
	davem@davemloft.net, joe.jin@oracle.com
To: fubar@us.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395998529-5937-1-git-send-email-zheng.x.li@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jay,
What's you think about the new patch.

Thanks,
Zheng Li

=D3=DA 2014=C4=EA03=D4=C228=C8=D5 17:22, Zheng Li =D0=B4=B5=C0:
> In bond mode tlb and alb, inactive slaves should keep inactive flag t=
o 1 to
> refuse to receive broadcast packets. Now, active slave send broadcast=
 packets
> (for example ARP requests) which will arrive inactive slaves on same =
host from
> switch, but inactive slave's inactive flag is zero that cause bridge =
receive the
> broadcast packets to produce a wrong entry in forward table. Typical =
situation
> is domu send some ARP request which go out from dom0 bond's active sl=
ave, then
> the ARP broadcast request packets go back to inactive slave from swit=
ch, because
> the inactive slave's inactive flag is zero, kernel will receive the p=
ackets and
> pass them to bridge that cause dom0's bridge map domu's MAC address t=
o port of
> bond, bridge should map domu's MAC to port of vif.
>=20
> Signed-off-by: Zheng Li <zheng.x.li@oracle.com>
> ---
>  drivers/net/bonding/bond_main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index e5628fc..f97d72e 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -3058,7 +3058,7 @@ static int bond_open(struct net_device *bond_de=
v)
>  	if (bond_has_slaves(bond)) {
>  		read_lock(&bond->curr_slave_lock);
>  		bond_for_each_slave(bond, slave, iter) {
> -			if ((bond->params.mode =3D=3D BOND_MODE_ACTIVEBACKUP)
> +			if ((bond->params.mode =3D=3D BOND_MODE_ACTIVEBACKUP || bond_is_l=
b(bond))
>  				&& (slave !=3D bond->curr_active_slave)) {
>  				bond_set_slave_inactive_flags(slave,
>  							      BOND_SLAVE_NOTIFY_NOW);
>=20
