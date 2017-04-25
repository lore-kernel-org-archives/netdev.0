From: Benjamin Poirier <bpoirier@suse.com>
Subject: Re: [Intel-wired-lan] [PATCH 1/2] e1000e: Don't return uninitialized
 stats
Date: Tue, 25 Apr 2017 11:44:23 -0700
Message-ID: <20170425184423.lg6rqgjeucjxqne2@f1.synalogic.ca>
References: <20170421212012.25950-1-bpoirier@suse.com>
 <630A6B92B7EDEB45A87E20D3D286660171182EED@hasmsx109.ger.corp.intel.com>
 <caef8d69-9e47-bbcc-0758-e5900e1cb291@intel.com>
 <20170424191026.wpnpyhdaurfjixl7@f1.synalogic.ca>
 <309B89C4C689E141A5FF6A0C5FB2118B8C5EF4F7@ORSMSX101.amr.corp.intel.com>
 <1493111272.68612.2.camel@intel.com>
 <20170425105405.01541742@xeon-e3>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="vofgzqnt4wm56pq5"
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        "Brown, Aaron F" <aaron.f.brown@intel.com>,
        "Neftin, Sasha" <sasha.neftin@intel.com>,
        David S Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org,
        Stefan Priebe <s.priebe@profihost.ag>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:48373 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1429851AbdDYSo3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Apr 2017 14:44:29 -0400
Content-Disposition: inline
In-Reply-To: <20170425105405.01541742@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--vofgzqnt4wm56pq5
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 2017/04/25 10:54, Stephen Hemminger wrote:
[...]
> > > The call to memset was removed from the upstream kernel with:
> > > -------------------------------------------------------------------
> > > -----------------
> > > commit 5944701df90d9577658e2354cc27c4ceaeca30fe
> > > Author: stephen hemminger <stephen@networkplumber.org>
> > > Date:=A0=A0 Fri Jan 6 19:12:53 2017 -0800
> > >=20
> > > =A0=A0=A0 net: remove useless memset's in drivers get_stats64
> > >=20
> > > =A0=A0=A0 In dev_get_stats() the statistic structure storage has alre=
ady
> > > been
> > > =A0=A0=A0 zeroed. Therefore network drivers do not need to call memse=
t()
> > > again.
> > > ...
> > > < changes to other drivers snipped out >
> > > ...
> > > diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c
> > > b/drivers/net/ethernet/int
> > > index 723025b..79651eb 100644
> > > --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> > > +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> > > @@ -5925,7 +5925,6 @@ void e1000e_get_stats64(struct net_device
> > > *netdev,
> > > =A0{
> > > =A0=A0=A0=A0=A0=A0=A0 struct e1000_adapter *adapter =3D netdev_priv(n=
etdev);
> > >=20
> > > -=A0=A0=A0=A0=A0=A0 memset(stats, 0, sizeof(struct rtnl_link_stats64)=
);
> > > =A0=A0=A0=A0=A0=A0=A0 spin_lock(&adapter->stats64_lock);
> > > =A0=A0=A0=A0=A0=A0=A0 e1000e_update_stats(adapter);
> > > =A0=A0=A0=A0=A0=A0=A0 /* Fill out the OS statistics structure */
> > > -------------------------------------------------------------------
> > > -----------------
> > >=20
> > > This also is where the bad counters start to show up for e1000e for
> > > my test systems.=A0 From this driver on I see (very) large values for
> > > tx_dropped, rx_over_errors and tx_fifo_errors on driver load (even
> > > before bringing the interface up.=A0 It seems the memset is not so
> > > useless for this driver after all.=A0 Would simply reverting the e100=
0e
> > > portion of this patch resolve the issue? =20
> >=20
> > Looks like Aaron beat me to the punch on pointing out that we had this
> > very code in there before.  It appears that Stephen's
> > assertion/assumption was incorrect about the stats structure being
> > zero'd out, which is why we are seeing the issue.
> >=20
> > I have no issue reverting Stephen's earlier patch, or do we want to
> > pursue why the stats structure is not zero'd out and resolve that
> > instead.  Either way, just want to make sure we are all on the same
> > page as to the right solution so that we do not end up repeating this
> > in the future.
>=20
> Lets's fix this in the base code.
>=20
> From: Stephen Hemminger <sthemmin@microsoft.com>
> Date: Tue, 25 Apr 2017 10:50:19 -0700
> Subject: [PATCH net] net: always zero statistics
>=20
> Drivers with 32 bit statistics API also should get zeroed statistics.
>=20
> Fixes: 5944701df90d ("net: remove useless memset's in drivers get_stats64=
")

This is probably a good change to do but it doesn't fix anything in
5944701df90d, especially not the problem with e1000e.

--vofgzqnt4wm56pq5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkvpDtefvZykbqQVOaJBbS33YWS0FAlj/mQcACgkQaJBbS33Y
WS0pIQ//aHIMlVxjbbOQ1sCcA9lQO/zaj0BI8ADVdr+4ovzZrNDDyMSGIMOcOeN9
cHYI3IMAfuFojCrtXZ9j3dIBLo974J+ivfskOGyWXWPhDdiJhMlijqHgX60n/LTt
fR5oxY/YXzy38/JOOA5sYDgttDvSymTbv1/QKfEkTs2Wr9iHEUMFvOoIVVWs76XR
+D+DFlqfxo9bNyskrZgYwXZkF9vC5asj4JOWZE4d3ZgEAPQDKgaypo9fr8ghAXTy
NGAj2uXKogX1oTmmYU1qMa05Mv09OaRAjq7RkkAB0WlqtMjMyilNp3bPnh9d7JUG
Go1NJV/gkL6FMFSHP0Ov28BXSHcki6V4n0ejHEgCCTMhS+fp4adl5WpZRe329dhf
bLqArEXMXXVatKow2Ja4zuQSkec8wPZL9Gv7UHBGJUFDwQ82DSM928qReQsA6yOF
bFk2hrZv/chU1GUWn2WqFQQjTbmvQLb5AqQc6a7aJBt3w4pELCQVFcoulZnqIqy3
vPuz4myzr1r5k1Qnx3gQg6V/3pfU/BjquxINrDN6znRWVPuNgBWC1gYXnn2X6gDn
KBqbVrKPQUCHXCQOxrT3473lj43v97YklhZ40Y53eBWqKjBayTHxBp2uCcYj4Y3R
WE8LPJHfe587/ri7CAGnOTpNNebvlYhLik2YOp5TaeXgsiBl0Ws=
=07BZ
-----END PGP SIGNATURE-----

--vofgzqnt4wm56pq5--
