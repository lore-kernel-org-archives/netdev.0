From: Jack Morgenstein <jackm@dev.mellanox.co.il>
Subject: Re: mlx4_core: Modify driver initialization flow to accommodate SRIOV for Ethernet
Date: Sat, 9 Jun 2012 14:29:16 +0300
Message-ID: <201206091429.17171.jackm@dev.mellanox.co.il>
References: <20120609090918.GB877@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, dotanb@mellanox.co.il,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:47553 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884Ab2FIL1a convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2012 07:27:30 -0400
Received: by weyu7 with SMTP id u7so1097957wey.19
        for <netdev@vger.kernel.org>; Sat, 09 Jun 2012 04:27:28 -0700 (PDT)
In-Reply-To: <20120609090918.GB877@elgon.mountain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 09 June 2012 12:09, Dan Carpenter wrote:
> =A0 =A0423 =A0 =A0 =A0 =A0 =A0/*fail if the hca has an unknown capabi=
lity */
> =A0 =A0424 =A0 =A0 =A0 =A0 =A0if ((hca_param.global_caps | HCA_GLOBAL=
_CAP_MASK) !=3D
> =A0 =A0425 =A0 =A0 =A0 =A0 =A0 =A0 =A0HCA_GLOBAL_CAP_MASK) {
> =A0 =A0426 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mlx4_err(dev, "Unknown =
hca global capabilities\n");
> =A0 =A0427 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOSYS;
> =A0 =A0428 =A0 =A0 =A0 =A0 =A0}
>=20
> The test sort of makes sense but HCA_GLOBAL_CAP_MASK is zero so we co=
uld
> as well say:
>=20
> =A0=A0=A0=A0=A0=A0=A0=A0if (hca_param.global_caps) { ...
>=20
The parameter global_caps is to guarantee that the guest OS is capable
of supporting the driver which is running on the master (hypervisor).

If a new feature impacts the guests, we will define a bit in the
global_caps bitmask and the master driver will set this bit and
the global_caps bitmask with the newly set bit will be passed
to the slaves.

The HCA_GLOBAL_CAP_MASK on the slave OS represents the set
of such features which the slave knows how to support.
If a new feature appears which is not set in the slave's
HCA_GLOBAL_CAP_MASK, this test detects the discrepancy and
the slave driver aborts.

This global_caps parameter passed from the master to the slave
is currently zero, because all current master capabilities
are supported on the slaves.

In the (probably near) future, when new capabilities are added,
Slave O/S's will also need to be updated.  If the master O/S driver is
updated, but an older slave O/S driver  isstill installed, the test
will fail and the driver on the slave will abort.

-Jack
