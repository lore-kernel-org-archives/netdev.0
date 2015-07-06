From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH V3 0/2] pci: Provide a flag to access
 VPD through function 0
Date: Mon, 6 Jul 2015 17:31:59 +0000
Message-ID: <C468F237-DBA2-4503-BA99-76CC1FC46999@intel.com>
References: <20150603184445.109080.36387.stgit@mdrustad-wks.jf.intel.com>
 <051B68B4-3E77-4EB0-B9FE-8523631884A2@intel.com>
 <45099CC7-DDAB-41D9-AB74-5A81E2AAF64C@intel.com>
 <CAErSpo7e-QtQQTj2yh_jG07vqU1j1YBez_9wrcrzOQs7+eDFng@mail.gmail.com>
 <8CB0ECE7-CFE2-43CB-BA60-2E2E0A34D5D1@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_E609F99B-3604-41C9-B72C-3A4D69904F95";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Bjorn Helgaas <bhelgaas@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:2541 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754133AbbGFRcB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jul 2015 13:32:01 -0400
In-Reply-To: <8CB0ECE7-CFE2-43CB-BA60-2E2E0A34D5D1@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_E609F99B-3604-41C9-B72C-3A4D69904F95
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

> On Jun 26, 2015, at 11:04 AM, Rustad, Mark D <mark.d.rustad@intel.com> =
wrote:
>=20
>> Sorry, Mark, I've just been busy with other issues and haven't had a
>> chance to look at this yet.
>=20
> Is there any chance of this getting into this merge window?

Well, it has missed the merge window, but this really is a bug fix. =
These patches address problems that, under race conditions, can corrupt =
VPD data and under other conditions can cause hangs. In fact I would =
submit that the reason that the VPD operations have been made =
interruptible is directly related to hangs caused by the sharing of VPD =
capability registers between functions. You see, if one function ever =
performs a VPD write, any subsequent read on any other function that =
shares those registers will definitely hang.

I imagine that there are many devices beyond Intel's Ethernet devices =
that would benefit from using the quirk that these patches introduce.

Please apply it and consider it for -stable.

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_E609F99B-3604-41C9-B72C-3A4D69904F95
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJVmruPAAoJEDwO/+eO4+5u5pUP/0QYadQsnrPmVE5MipgcRZ0X
StIZbIASI3FnZvVQxqc2Os0Oe5QAX334/sneRR+3zs9S+jc5PdF9VxVK7UbHX1qk
Ypn6FBYrWcYPz4ipkg7HmpwNTB5lbqObUqOcmMhN07WEsCvkhmvDhbYnwUH4i45W
ikt8AzQRRWF9A/eiN66Y83H3ODOu6gXTFO8jGzS1scwlNHiCpuE4Z9/sKd42h9sv
imosZ25X+6R6cgO6yEcm7UTTIjfZ/V9qqbAquZOyBZp0WBqYwh6ODvqVhJkmEPi+
mjVKrueBoToZEf+6iQ2dTyxtJZRrerj2wvzDVh6OjNo+/JvmzVLjo5J0fGDqGPcl
Yx5BYVtYR6UnoI0vEVnjFuQFixw7JoCCMelnA/EnPJzHwHRaY7+01LYylEyghEkl
Qx/rKzpgIYo1Y2XhJi3XhaFVMIjapKG8N1thqLybOnG2abvxJgk5/GUVoI4HdQ5c
BD/bvjovtszTpLMI3q7QDQ1JMkFR3ce476rj13YPI3/o3ytaK7XSm/8MnTiqkJsX
rWjmPBXHIq/RHf67f1NOhBiVxu5cdgYhv5CeP4ekXA/FnUsjZjuUI1hspolwi3rl
RS1vAiuT+Qk+eOmi/ZeS7vZIyW/Jl4I9i50DrvQ2nUH5gNaQeSHalFeGoQtNF2iS
UgTeiunlvqVy3Kw9PCEI
=GBnj
-----END PGP SIGNATURE-----

--Apple-Mail=_E609F99B-3604-41C9-B72C-3A4D69904F95--
