From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH v1 net-next 2/2] igb: support SIOCSMIIREG
Date: Thu, 7 May 2015 20:46:15 +0000
Message-ID: <93C443E7-4209-45A3-A54F-949A4ECDD508@intel.com>
References: <1429302240-654-1-git-send-email-jtoppins@cumulusnetworks.com>
 <1429302240-654-2-git-send-email-jtoppins@cumulusnetworks.com>
 <554BA646.1060000@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_F7A7C139-75B3-4867-B127-46EC277C1966";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: Jonathan Toppins <jtoppins@cumulusnetworks.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"shm@cumulusnetworks.com" <shm@cumulusnetworks.com>,
	Alan Liebthal <alanl@cumulusnetworks.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:7745 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751663AbbEGUqT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2015 16:46:19 -0400
In-Reply-To: <554BA646.1060000@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_F7A7C139-75B3-4867-B127-46EC277C1966
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252

> On May 7, 2015, at 10:52 AM, Alexander Duyck =
<alexander.duyck@gmail.com> wrote:
>=20
>> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c =
b/drivers/net/ethernet/intel/igb/igb_main.c
>> index 720b785..1071a71 100644
>> --- a/drivers/net/ethernet/intel/igb/igb_main.c
>> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
>> @@ -7141,6 +7141,11 @@ static int igb_mii_ioctl(struct net_device =
*netdev, struct ifreq *ifr, int cmd)
>>  			return -EIO;
>>  		break;
>>  	case SIOCSMIIREG:
>> +		adapter->hw.phy.addr =3D data->phy_id;
>> +		if (igb_write_phy_reg(&adapter->hw, data->reg_num & =
0x1F,
>> +				      data->val_in))
>> +			return -EIO;
>> +		break;
>>  	default:
>>  		return -EOPNOTSUPP;
>>  	}
>=20
> How and why is this being used?  =46rom what I can tell it looks like =
it is an easy way to break any of the existing interfaces if it is =
misused since all you would need to do is specify a phy address that =
doesn't match the existing PHY in the system and then you would likely =
lose link, or possibly mess up the configuration on the system =
requiring.
>=20
> I suspect this is a back door for some piece of user space code that =
is being given far more permission than it should be.

I don't know about a back door, but the real problem is that it has a
side-effect of changing the saved value of the phy addr. That is clearly
a problem and can't be allowed.

For the phylib stuff to really work as intended, the igb_write_phy_reg
really should take the phy address as a parameter instead of getting
the value from the structure itself. Or a new function should be
defined that has that interface.

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_F7A7C139-75B3-4867-B127-46EC277C1966
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJVS88WAAoJEDwO/+eO4+5uVDMP/jDDV33fSzCYfHmr5H5AbiZB
k7DNfhxEVUOTfZxxKzxI2uTjPLtamL7y3yBsrqc5t/NBesuAzYIQmce/OSaWQUAI
Jyyj8FxuVkPyrFOwZst0F86wO6zdNuYQ0A32Nw3AHylL5nLnnjqy8FXHWlHEKzQh
vOIFlkshlG7Lr3yAvYka5Y8wjAkVmrQuzkPpY77N5qRBF3ijAqn0ajBPOZscys7N
Gb7WArg2ESb9Omg7qx4LvwzWB17xi5hGhg7Mu7ihwhJylYD7ypDqDCmdhNm5u+9n
xwLl+5Dbu64iRnXbpKkNnmKKTIpK6C/hRNN/zbs9NyfStWXpGB70a3Rjw25MHsN2
qmTnOWnemZ//L9ebRh8Haes+L9WxJUkKunwnCSa8fjlK5Pxq/JuQ4lYvFIxoL8nH
yUfvEUx+KQNBKM8L+LxrNZuWOaiMj2l2OQ+xuTe4hCv2baQjvdUirWn3Jfvn/4pk
Xrf4HoZ4S9InVGOzaEjcqW2PDbSbnkXAK3MJcBV15AnPj5Ma8tC5eEyulTHhRCOp
WBoBNvOEJMAp/VpTTigAnKCO0xrvBFmIqxULPRFuKYEwdP39QZ5Myluu3kqpmNpm
veqp+nTYxfQFs+M7I2aMm5aAYRWYo0e3JBCHsZnje7TiClvmEBJZIOYOkWfp/hmD
xV7Etxv3MwZ1aGEs7Dz7
=plcV
-----END PGP SIGNATURE-----

--Apple-Mail=_F7A7C139-75B3-4867-B127-46EC277C1966--
