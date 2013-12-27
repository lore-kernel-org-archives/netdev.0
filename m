From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 2/2] ixgbe: set driver_max_VFs should be
 done before enabling SRIOV
Date: Fri, 27 Dec 2013 01:03:23 -0800
Message-ID: <1388135003.2183.145.camel@jtkirshe-mobl>
References: <1387901251-1672-1-git-send-email-ethan.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7217586863618566306=="
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	linux-kernel@vger.kernel.org, davem@davemloft.net
To: Ethan Zhao <ethan.kernel@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1387901251-1672-1-git-send-email-ethan.kernel@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============7217586863618566306==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-w8qPRrrI0g8Z0RHX0NYt"


--=-w8qPRrrI0g8Z0RHX0NYt
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2013-12-25 at 00:07 +0800, Ethan Zhao wrote:
> commit 43dc4e01 Limit number of reported VFs to device specific value
> It doesn't work and always returns -EBUSY because VFs ware already
> enabled.
>=20
> ixgbe_enable_sriov()
>         pci_enable_sriov()
>                 sriov_enable()
>                 {
>                 ... ..
>                 iov->ctrl |=3D PCI_SRIOV_CTRL_VFE | PCI_SRIOV_CTRL_MSE;
>                 pci_cfg_access_lock(dev);
>                 ... ...
>                 }
>=20
> pci_sriov_set_totalvfs()
> {
> ... ...
> if (dev->sriov->ctrl & PCI_SRIOV_CTRL_VFE)
>                 return -EBUSY;
> ...
> }
>=20
> So should set driver_max_VFs with pci_sriov_set_totalvfs() before
> enable VFs with ixgbe_enable_sriov().
>=20
> Signed-off-by: Ethan Zhao <ethan.kernel@gmail.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Thanks Ethan, I have added this patch as well to my queue.

--=-w8qPRrrI0g8Z0RHX0NYt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSvUJbAAoJEOVv75VaS+3OFf0P/3A2eH7tHcNsfM0FtBH/iFGj
PBKsJ+z4ObPUCmQoJEiVUHM9N6cpfYs9aD0ph9ktfAN9N2tvxfiKR+CXUetS+RYL
WqAM+35Uhy4b26MyceLn/0Xeo3V3de7aZuWgmRPvVWrZkuOOooj8J6CUusqihuvh
NGKwZ/PAB/ZuZ1frhndy8rBZRlkxxJpYt7j40jZlARoay4/LmuPZhM0fEZSpIPCq
SwkI0WsPewnwH+0u95b8QSMYXYMF/UP5PgkXf1O7pzgsW3hVHmU9AiiPwJXSf4eq
zMiF2OLrPU61DnOFb58oEfHvPCwrYO6GkJ6CvZtrH9LKQJmreZaJMRVFnjc44vSe
GmtmcMda8QpOvrfuboDxkM4X/zVsdv2RZKbuoiYit/mh7ZS9ohlYGRQgrA8DlMP2
XgDmq3TZq/QTbDe2o3yzBmRi8CfNufgrUS8eolk9es/OH9hxjV+DHAWFsM7ZBEce
DC/5EUG9X24x2E7gCKbxv/V6+Hf58qhMYfg9VbENczXo/Rhp4XZzyveqEWQCOQCV
1sIoCXlIMudzWAJNXxjSKY0YMlkjXe3kzT9CCIQCtrGcBo5PbrAhuQEnUPW23X00
An6img9c5HSwp54A8Po5NnRoWZb14vlOG+P73wQLzEcYRnYyhc0VX3bVXuszXVyl
Q/dNNac4yhMyeF13YkDP
=5G+d
-----END PGP SIGNATURE-----

--=-w8qPRrrI0g8Z0RHX0NYt--



--===============7217586863618566306==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Rapidly troubleshoot problems before they affect your business. Most IT 
organizations don't have a clear picture of how application performance 
affects their revenue. With AppDynamics, you get 100% visibility into your 
Java,.NET, & PHP application. Start your 15-day FREE TRIAL of AppDynamics Pro!
http://pubads.g.doubleclick.net/gampad/clk?id=84349831&iu=/4140/ostg.clktrk
--===============7217586863618566306==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============7217586863618566306==--
