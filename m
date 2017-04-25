From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH 1/2] e1000e: Don't return
 uninitialized stats
Date: Tue, 25 Apr 2017 02:07:52 -0700
Message-ID: <1493111272.68612.2.camel@intel.com>
References: <20170421212012.25950-1-bpoirier@suse.com>
         <630A6B92B7EDEB45A87E20D3D286660171182EED@hasmsx109.ger.corp.intel.com>
         <caef8d69-9e47-bbcc-0758-e5900e1cb291@intel.com>
         <20170424191026.wpnpyhdaurfjixl7@f1.synalogic.ca>
         <309B89C4C689E141A5FF6A0C5FB2118B8C5EF4F7@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-AmY3Xy7yYvTdGbhgq+Eh"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "Kirsher@f1.synalogic.ca" <Kirsher@f1.synalogic.ca>,
        Stefan Priebe <s.priebe@profihost.ag>
To: "Brown, Aaron F" <aaron.f.brown@intel.com>,
        Benjamin Poirier <bpoirier@suse.com>,
        "Neftin, Sasha" <sasha.neftin@intel.com>,
        David S Miller <davem@davemloft.net>,
        stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:8833 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1176350AbdDYJIP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Apr 2017 05:08:15 -0400
In-Reply-To: <309B89C4C689E141A5FF6A0C5FB2118B8C5EF4F7@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-AmY3Xy7yYvTdGbhgq+Eh
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2017-04-25 at 07:10 +0000, Brown, Aaron F wrote:
> > From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.
> > org] On
> > Behalf Of Benjamin Poirier
> > Sent: Monday, April 24, 2017 12:10 PM
> > To: Neftin, Sasha <sasha.neftin@intel.com>
> > Cc: Kirsher@f1.synalogic.ca; Stefan Priebe <s.priebe@profihost.ag>;
> > netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org
> > Subject: Re: [Intel-wired-lan] [PATCH 1/2] e1000e: Don't return
> > uninitialized
> > stats
> >=20
> > Sasha, please use reply-all to keep everyone in cc (including
> > me...).
> >=20
> > On 2017/04/24 11:17, Neftin, Sasha wrote:
> > > On 4/23/2017 15:53, Neftin, Sasha wrote:
> > > > -----Original Message-----
> > > > From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osu
> > > > osl.org]
> >=20
> > On Behalf Of Benjamin Poirier
> > > > Sent: Saturday, April 22, 2017 00:20
> > > > To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>
> > > > Cc: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org;
> > > > Stefan
> >=20
> > Priebe <s.priebe@profihost.ag>
> > > > Subject: [Intel-wired-lan] [PATCH 1/2] e1000e: Don't return
> > > > uninitialized
> >=20
> > stats
> > > >=20
> > > > Some statistics passed to ethtool are garbage because
> >=20
> > e1000e_get_stats64() doesn't write them, for example:
> > tx_heartbeat_errors.
> > This leaks kernel memory to userspace and confuses users.
> > > >=20
> > > > Do like ixgbe and use dev_get_stats() which first zeroes out
> >=20
> > rtnl_link_stats64.
> > > >=20
> > > > Reported-by: Stefan Priebe <s.priebe@profihost.ag>
> > > > Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
> > > > ---
> > > > =C2=A0=C2=A0 drivers/net/ethernet/intel/e1000e/ethtool.c | 2 +-
> > > > =C2=A0=C2=A0 1 file changed, 1 insertion(+), 1 deletion(-)
> > > >=20
> > > > diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c
> >=20
> > b/drivers/net/ethernet/intel/e1000e/ethtool.c
> > > > index 7aff68a4a4df..f117b90cdc2f 100644
> > > > --- a/drivers/net/ethernet/intel/e1000e/ethtool.c
> > > > +++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
> > > > @@ -2063,7 +2063,7 @@ static void
> > > > e1000_get_ethtool_stats(struct
> >=20
> > net_device *netdev,
> > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0p=
m_runtime_get_sync(netdev->dev.parent);
> > > > -=C2=A0e1000e_get_stats64(netdev, &net_stats);
> > > > +=C2=A0dev_get_stats(netdev, &net_stats);
> > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0p=
m_runtime_put_sync(netdev->dev.parent);
> > > > --
> > > > 2.12.2
> > > >=20
> > > > _______________________________________________
> > > > Intel-wired-lan mailing list
> > > > Intel-wired-lan@lists.osuosl.org
> > > > http://lists.osuosl.org/mailman/listinfo/intel-wired-lan
> > >=20
> > > Hello,
> > >=20
> > > We would like to not accept this patch. Suggested generic method
> > > '*dev_get_stats' (net/core/dev.c) calls 'ops->ndo_get_stats64'
> > > method
> >=20
> > which
> > > eventually calls e1000e_get_stats64 (netdev.c) - so there is same
> > > functionality. Also, see that 'e1000e_get_stats64' method in
> > > netdev.c (line
> >=20
> > No, it's not the same functionality because dev_get_stats() does a
> > memset on the rtnl_link_stats64 struct.
> >=20
> > > 5928) calls 'memset' with 0's before update statistics.=C2=A0 Local
> > > sanity check
> >=20
> > I don't see any memset in e1000e_get_stats64(). What kernel version
> > are
> > you looking at?
>=20
> The call to memset was removed from the upstream kernel with:
> -------------------------------------------------------------------
> -----------------
> commit 5944701df90d9577658e2354cc27c4ceaeca30fe
> Author: stephen hemminger <stephen@networkplumber.org>
> Date:=C2=A0=C2=A0 Fri Jan 6 19:12:53 2017 -0800
>=20
> =C2=A0=C2=A0=C2=A0 net: remove useless memset's in drivers get_stats64
>=20
> =C2=A0=C2=A0=C2=A0 In dev_get_stats() the statistic structure storage has=
 already
> been
> =C2=A0=C2=A0=C2=A0 zeroed. Therefore network drivers do not need to call =
memset()
> again.
> ...
> < changes to other drivers snipped out >
> ...
> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c
> b/drivers/net/ethernet/int
> index 723025b..79651eb 100644
> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> @@ -5925,7 +5925,6 @@ void e1000e_get_stats64(struct net_device
> *netdev,
> =C2=A0{
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 struct e1000_adapter *adapter =
=3D netdev_priv(netdev);
>=20
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 memset(stats, 0, sizeof(struct rtnl=
_link_stats64));
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 spin_lock(&adapter->stats64_lo=
ck);
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 e1000e_update_stats(adapter);
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 /* Fill out the OS statistics =
structure */
> -------------------------------------------------------------------
> -----------------
>=20
> This also is where the bad counters start to show up for e1000e for
> my test systems.=C2=A0 From this driver on I see (very) large values for
> tx_dropped, rx_over_errors and tx_fifo_errors on driver load (even
> before bringing the interface up.=C2=A0 It seems the memset is not so
> useless for this driver after all.=C2=A0 Would simply reverting the e1000=
e
> portion of this patch resolve the issue?

Looks like Aaron beat me to the punch on pointing out that we had this
very code in there before.  It appears that Stephen's
assertion/assumption was incorrect about the stats structure being
zero'd out, which is why we are seeing the issue.

I have no issue reverting Stephen's earlier patch, or do we want to
pursue why the stats structure is not zero'd out and resolve that
instead.  Either way, just want to make sure we are all on the same
page as to the right solution so that we do not end up repeating this
in the future.
--=-AmY3Xy7yYvTdGbhgq+Eh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiTyZWz+nnTrOJ1LZ5W/vlVpL7c4FAlj/EegACgkQ5W/vlVpL
7c76Tw//ZoHhqhoM89YYWhFZd/v/Xx6NKulBEvqX922fUyWXUxxtYKX/mPa0rj5V
VZ2Ui3Ev+oANLSA5F4C51uC+NfvujM0igVovwqDacyb8tqKmepUjqjauQHV/bQ3p
S8hiGzM+I3AlMOSUF2igHkbGoO5NP0W+ryOQzrA/8xjXWlifvv0jGYSoAW0O5TbZ
ege2GmC9L7mPaaVR8j3Ii/Le8T8a6ujtFCyvE1DXAg959KzTB4mpbXusVQh9WeAm
2PBFfpCPRwToziLYAV+1FHwNYmaHc0Ek1tiEnTFBDyPA7NOC973PWrKRuhNhZ7B8
DBh2t0yfSfNeFo7QCF6DSfcXpVAPnO59DM4N29BI3GcC9BDWpulW1KWYqao25kVV
ctdw7B3kAWPku1PutMH+H1+YNufBlYMyZBXfCIiZrgaMHI3FglZT5bZMRCv1FlVX
XIhqHjpV9oKysoC9YxoxO5iCr/AZQ0DqA+E7VXyO2n5b+lbQhMK6kXgfSbZ5whIV
H9q+kFmVra1OW/Ba5vAeelCIMIYV2W946sANUEK4O4D61Xazro4o2J8Z5msM8Jie
oawaZCwbZ1pG9rx/ykIjlL0mwnFWFn4BwatYOkvrRrJaI+C7+WMtlJz1YsOIxyjr
UPKfc4tsOp+QGPGhCjFxLbbRQfByV9EpNNUUqlgfL1j1LkhV/6g=
=eOkx
-----END PGP SIGNATURE-----

--=-AmY3Xy7yYvTdGbhgq+Eh--
