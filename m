From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [net-next 3/7] ixgbe: Use static inlines instead of macros
Date: Thu, 9 Jan 2014 20:14:51 +0000
Message-ID: <25B12960-1709-4E96-A278-9DBF9009C0F5@intel.com>
References: <1389166847-3780-4-git-send-email-aaron.f.brown@intel.com>
 <CE14B815-C10B-4091-A608-6742117FBEF6@cumulusnetworks.com>
 <2C8FA848-3185-43BA-BDD7-955B0C7DD835@intel.com>
 <20140109.143923.437905458430188006.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_F4C0433C-80C8-4E8F-A0E4-4652DC07FDBC";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Cc: Scott Feldman <sfeldma@cumulusnetworks.com>,
	"Brown, Aaron F" <aaron.f.brown@intel.com>,
	Netdev <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:59895 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756062AbaAIUOx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 15:14:53 -0500
In-Reply-To: <20140109.143923.437905458430188006.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_F4C0433C-80C8-4E8F-A0E4-4652DC07FDBC
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Jan 9, 2014, at 11:39 AM, David Miller <davem@davemloft.net> wrote:

> From: "Rustad, Mark D" <mark.d.rustad@intel.com>
> Date: Thu, 9 Jan 2014 17:34:18 +0000
>=20
>> On Jan 8, 2014, at 12:47 AM, Scott Feldman =
<sfeldma@cumulusnetworks.com> wrote:
>>=20
>>>=20
>>> On Jan 7, 2014, at 11:40 PM, Aaron Brown <aaron.f.brown@intel.com> =
wrote:
>>>=20
>>>> From: Mark Rustad <mark.d.rustad@intel.com>
>>>>=20
>>>> -#define IXGBE_WRITE_REG(a, reg, value) writel((value), =
((a)->hw_addr + (reg)))
>>>> +static inline void IXGBE_WRITE_REG(struct ixgbe_hw *hw, u32 reg, =
u32 value)
>>>=20
>>> Bummer, now you have a all-caps func name.
>>=20
>> Agreed, but this is actually a fairly common condition among drivers =
that used to use macros. It isn't perfect, but at least it is moving in =
the right direction. I'd rather leave the case change for a later patch =
series that does only that or has some reason to touch all of the =
register access sites.
>>=20
>> At least the new accessor I introduced is lower case. :-)
>=20
> Please address this feedback, all caps function names are really not
> appropriate.

I really don't think it is a good idea to do that as part of this patch =
series. It makes this patch series a pretty solid barrier to any other =
patches going into this driver because it would change the name of all =
the register accessors.

This makes me want to deal with that as a separate issue, since there =
would be no functional reason to drop such a patch and it can be planned =
into a workflow.

Obviously I could do it here, but I *really* think it is procedurally a =
really bad idea to change the case as part of a functional change. I =
thought I was doing a favor my at least making them inlines, but prehaps =
not.

Anyone want to take on changing the upper case static inlines in =
mcf8390, 7990, benet, ns83820, s2io, vxge, iwlwifi, ath9k, wil6210, =
mwifiex, and rtlwifi? And those are just under drivers/net.

--=20
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_F4C0433C-80C8-4E8F-A0E4-4652DC07FDBC
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIbBAEBAgAGBQJSzwM6AAoJEDwO/+eO4+5ucPIP+NbWz+PU1tj9Kcqot63C7Y+F
8ht6SNZoOc9soWTy74vhFtJDV7X23v6m4nscKYgxFHi89NhT8lY+a4QyhYXzzcZa
RH+YL6sS1Gsq4eSkXs10DWYLtNeWBOP/J7mlaQ4USKlKV3bAGNg/Apl6/j6Q9WDM
PNNRzhBoIeRDhX0ql/Ci8J7xCnjpasyILDJRe3nhfgMdFFaMv34mSYDz5Z1syzwu
y/DTM8EbOXaqr6xePA+8cWw4ie/kcTRmNSMDtMPeyZZS8EsRK+d9ooh247aufX9G
v19iclqr5cKRWUUsKRo7bUc/WL4jkGE83AfYzeyd/AngiyicrIRcuWzIVqP1WVin
mnt4kZn3Scb3EUiHQ1UaHCv0WMRWMs+xjGO0maM84MScQ24caSuXdi0xApYc+0jm
G1YwOQcOoo2CCvitn0vrK7EHciLnFFW3V5d0L/5X7T2yASQtuFFxjLvwfkPZBHiy
CdE5D171KxdpaV/uSdIxoJbOX7G/EWLVfp6nT58UDdMIjJb4IMhtxQWYZpGOR32P
tjJ8SjXoWUYFvbz4aQj5xm03ghHGjEtePlysipSQH95Fh7BIGW6JpFwJuOtclcWQ
OBaP2X47cSp1unwr3QYQovaDm/ddfVgEUxZ3gQX8rOl5ik//oC+Uy3Hmi+h30GyF
38CjPVq0TTe2CH7Fdo4=
=BHig
-----END PGP SIGNATURE-----

--Apple-Mail=_F4C0433C-80C8-4E8F-A0E4-4652DC07FDBC--
