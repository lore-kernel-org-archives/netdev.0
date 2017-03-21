From: "Mody, Rasesh" <Rasesh.Mody@cavium.com>
Subject: RE: [PATCH] bna: integer overflow bug in debugfs
Date: Tue, 21 Mar 2017 01:14:05 +0000
Message-ID: <BLUPR0701MB15723BB97F9129EC1020326E9F3D0@BLUPR0701MB1572.namprd07.prod.outlook.com>
References: <20170317205234.GA2888@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>,
        Dept-GE Linux NIC Dev <Dept-GELinuxNICDev@cavium.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>,
        Krishna Gudipati <kgudipat@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0080.outbound.protection.outlook.com ([104.47.36.80]:16256
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754163AbdCUBQJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 21:16:09 -0400
In-Reply-To: <20170317205234.GA2888@mwanda>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Dan Carpenter [mailto:dan.carpenter@oracle.com]
> Sent: Friday, March 17, 2017 1:53 PM
>=20
> We could allocate less memory than intended because we do:
>=20
> 	bnad->regdata =3D kzalloc(len << 2, GFP_KERNEL);
>=20
> The shift can overflow leading to a crash.  This is debugfs code so the i=
mpact
> is very small.
>=20
> Fixes: 7afc5dbde091 ("bna: Add debugfs interface.")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>=20
> diff --git a/drivers/net/ethernet/brocade/bna/bnad_debugfs.c
> b/drivers/net/ethernet/brocade/bna/bnad_debugfs.c
> index 05c1c1dd7751..cebfe3bd086e 100644
> --- a/drivers/net/ethernet/brocade/bna/bnad_debugfs.c
> +++ b/drivers/net/ethernet/brocade/bna/bnad_debugfs.c
> @@ -325,7 +325,7 @@ bnad_debugfs_write_regrd(struct file *file, const
> char __user *buf,
>  		return PTR_ERR(kern_buf);
>=20
>  	rc =3D sscanf(kern_buf, "%x:%x", &addr, &len);
> -	if (rc < 2) {
> +	if (rc < 2 || len > UINT_MAX >> 2) {
>  		netdev_warn(bnad->netdev, "failed to read user buffer\n");
>  		kfree(kern_buf);
>  		return -EINVAL;

You are correct, thanks Dan for adding the check.

Acked-by: Rasesh Mody <rasesh.mody@cavium.com>
