From: "zheng.li" <zheng.x.li@oracle.com>
Subject: Re: [PATCH v3] bonding: Inactive slaves should keep inactive flag's
 value
Date: Thu, 03 Apr 2014 10:16:01 +0800
Message-ID: <533CC461.4070209@oracle.com>
References: <1396407708-4056-1-git-send-email-zheng.x.li@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Zheng Li <zheng.x.li@oracle.com>, netdev@vger.kernel.org,
	fubar@us.ibm.com, andy@greyhouse.net, vfalico@redhat.com,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	joe.jin@oracle.com
To: j.vosburgh@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1396407708-4056-1-git-send-email-zheng.x.li@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jay,
How do you think about the new patch used USES_PRIMARY, can it be merge=
d
to upstream?

Thanks,
Zheng Li


=D3=DA 2014=C4=EA04=D4=C202=C8=D5 11:01, Zheng Li =D0=B4=B5=C0:
> bond_open is not setting the inactive flag correctly for some modes (=
alb and
> tlb), resulting in error behavior if the bond has been administrative=
ly set
> down and then back up. This effect should not occur when slaves are a=
dded while
> the bond is up; it's something that only happens after a down/up boun=
ce of the
> bond.
>=20
> For example, in bond tlb or alb mode, domu send some ARP request whic=
h go out
> from dom0 bond's active slave, then the ARP broadcast request packets=
 go back to
> inactive slave from switch, because the inactive slave's inactive fla=
g is zero,
> kernel will receive the packets and pass them to bridge that cause do=
m0's bridge
> map domu's MAC address to port of bond, bridge should map domu's MAC =
to port of
> vif.
>=20
> Signed-off-by: Zheng Li <zheng.x.li@oracle.com>
> Signed-off-by: Jay Vosburgh <j.vosburgh@gmail.com>
> ---
>  drivers/net/bonding/bond_main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index e5628fc..b42758f 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -3058,7 +3058,7 @@ static int bond_open(struct net_device *bond_de=
v)
>  	if (bond_has_slaves(bond)) {
>  		read_lock(&bond->curr_slave_lock);
>  		bond_for_each_slave(bond, slave, iter) {
> -			if ((bond->params.mode =3D=3D BOND_MODE_ACTIVEBACKUP)
> +			if (USES_PRIMARY(bond->params.mode)
>  				&& (slave !=3D bond->curr_active_slave)) {
>  				bond_set_slave_inactive_flags(slave,
>  							      BOND_SLAVE_NOTIFY_NOW);
>=20
