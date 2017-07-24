From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH V4 net-next 7/8] net: hns3: Add Ethtool support to HNS3
 driver
Date: Mon, 24 Jul 2017 20:32:07 +0000
Message-ID: <D7C5EFE3-632C-468D-B8E0-82B448634B31@intel.com>
References: <20170722220942.78852-1-salil.mehta@huawei.com>
 <20170722220942.78852-8-salil.mehta@huawei.com>
 <23ddbe00-8bef-a09b-5783-3a5438086bd6@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
        boundary="Apple-Mail=_8826735D-3F14-4F03-BD30-C8A3C6E0187D";
        protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: Salil Mehta <salil.mehta@huawei.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "yisen.zhuang@huawei.com" <yisen.zhuang@huawei.com>,
        "huangdaode@hisilicon.com" <huangdaode@hisilicon.com>,
        "lipeng321@huawei.com" <lipeng321@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linuxarm@huawei.com" <linuxarm@huawei.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:61035 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753565AbdGXUcL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Jul 2017 16:32:11 -0400
In-Reply-To: <23ddbe00-8bef-a09b-5783-3a5438086bd6@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_8826735D-3F14-4F03-BD30-C8A3C6E0187D
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


> On Jul 23, 2017, at 10:05 AM, Florian Fainelli <f.fainelli@gmail.com> =
wrote:
>> +
>> +	strncpy(drvinfo->version, HNAE_DRIVER_VERSION,
>> +		sizeof(drvinfo->version));
>> +	drvinfo->version[sizeof(drvinfo->version) - 1] =3D '\0';
>=20
> strlcpy() would probably do that for you.

You need to be careful about strlcpy - it does not completely write the =
destination buffer as strncpy does, and so can result in a kernel memory =
leak if the destination is not known to already be cleared.

>> +
>> +	strncpy(drvinfo->driver, HNAE_DRIVER_NAME, =
sizeof(drvinfo->driver));
>> +	drvinfo->driver[sizeof(drvinfo->driver) - 1] =3D '\0';
>=20
> Same here

Same here

>> +
>> +	strncpy(drvinfo->bus_info, priv->dev->bus->name,
>> +		sizeof(drvinfo->bus_info));> +	=
drvinfo->bus_info[ETHTOOL_BUSINFO_LEN - 1] =3D '\0';
>=20
> And here.

And here too. I haven't looked at this deeply enough to know whether a =
leak could be created by strlcpy here, but I wanted to raise it as =
something to be considered before switching to it. Blindly adopting =
strlcpy is hazardous as are tools that unconditionally recommend it.
--Apple-Mail=_8826735D-3F14-4F03-BD30-C8A3C6E0187D--
