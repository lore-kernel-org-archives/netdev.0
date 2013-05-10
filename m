From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH 06/11] net/bonding: take msecs_to_jiffies_min into use
Date: Fri, 10 May 2013 15:58:10 +0200
Message-ID: <20130510135810.GA30139@unicorn.suse.cz>
References: <1368188011-23661-1-git-send-email-imre.deak@intel.com>
 <1368188011-23661-6-git-send-email-imre.deak@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Imre Deak <imre.deak@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1368188011-23661-6-git-send-email-imre.deak@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 10, 2013 at 03:13:24PM +0300, Imre Deak wrote:
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1751,7 +1751,7 @@ int bond_enslave(struct net_device *bond_dev, s=
truct net_device *slave_dev)
>  	read_lock(&bond->lock);
> =20
>  	new_slave->last_arp_rx =3D jiffies -
> -		(msecs_to_jiffies(bond->params.arp_interval) + 1);
> +		(msecs_to_jiffies_min(bond->params.arp_interval));
> =20
>  	if (bond->params.miimon && !bond->params.use_carrier) {
>  		link_reporting =3D bond_check_dev_link(bond, slave_dev, 1);

This "+ 1" was actually meant as "plus one". We need to ensure that

  slave->last_arp_rx + msecs_to_jiffies(bond->params.arp_interval)

is strictly less than current value of jiffies. So with proposed
definition of msecs_to_jiffies_min() it works correctly but if the
implementation ever changes in such way that

  msecs_to_jiffies_min(x) >=3D msecs_to_jiffies(x)

for some value of x, the code would be incorrect.

                                                       Michal Kube=E8ek
