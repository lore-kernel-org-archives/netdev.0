From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH] pci: Limit VPD reads for all Intel
 Ethernet devices
Date: Tue, 19 May 2015 16:19:23 +0000
Message-ID: <4AD84211-965C-4F0B-A7F4-3E6CCE6567E3@intel.com>
References: <20150519000042.56109.69779.stgit@mdrustad-wks.jf.intel.com>
 <555B5CBF.1090902@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_0EC29573-34CF-4539-8667-0C8BB8CA778C";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "bhelgaas@google.com" <bhelgaas@google.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <555B5CBF.1090902@redhat.com>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Apple-Mail=_0EC29573-34CF-4539-8667-0C8BB8CA778C
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252

> On May 19, 2015, at 8:54 AM, Alexander Duyck =
<alexander.h.duyck@redhat.com> wrote:
>=20
> On 05/18/2015 05:00 PM, Mark D Rustad wrote:
>> To save boot time and some memory, limit VPD size to the maximum
>> possible for all Intel Ethernet devices that have VPD, which is 1K.
>>=20
>> Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
>> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> ---
>>  drivers/pci/quirks.c |    7 +++++--
>>  1 file changed, 5 insertions(+), 2 deletions(-)
>>=20
>> diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
>> index c6dc1dfd25d5..4fabbeda964a 100644
>> --- a/drivers/pci/quirks.c
>> +++ b/drivers/pci/quirks.c
>> @@ -1903,12 +1903,15 @@ static void quirk_netmos(struct pci_dev *dev)
>>  DECLARE_PCI_FIXUP_CLASS_HEADER(PCI_VENDOR_ID_NETMOS, PCI_ANY_ID,
>>  			 PCI_CLASS_COMMUNICATION_SERIAL, 8, =
quirk_netmos);
>>  -static void quirk_e100_interrupt(struct pci_dev *dev)
>> +static void quirk_intel_enet(struct pci_dev *dev)
>>  {
>>  	u16 command, pmcsr;
>>  	u8 __iomem *csr;
>>  	u8 cmd_hi;
>>  +	if (dev->vpd)
>> +		dev->vpd->len =3D 0x400;
>> +
>>  	switch (dev->device) {
>>  	/* PCI IDs taken from drivers/net/e100.c */
>>  	case 0x1029:

> I wasn't a fan of the first VPD patch and this clinches it.  What I =
would recommend doing is identifying all of the functions for a given =
device that share a VPD and then eliminate the VPD structure for all but =
the first function.  By doing that the OS should treat the other =
functions as though their VPD areas don't exist.

Please, lets discuss only *this* patch in this thread. The patches are =
not related except that they both have to do with VPD.

<snip>

> Artificially limiting the size of the VPD does nothing but cut off =
possibly useful data, you would be better of providing all of the data =
on only the first function than providing only partial data on all =
functions and adding extra lock overhead.

This limit only limits the maximum that the OS will read to what is =
architecturally possible in these devices. Yes, PCIe architecturally =
provides for the possibility of more, but these devices do not. More =
repeating data can be read, however slowly, but there is no possibility =
of useful content beyond the first 1K. If this limit were set to 0x100, =
which is more in line what the actual usage is, it would be an =
artificial limit, but at 1K it is not. Oh and it does include devices =
made by others that incorporate Intel Ethernet silicon, not just =
Intel-built devices.

Since this quirk function was already being run for every Intel Ethernet =
device, this seemed like a trivial thing to do to speed up booting a =
bit. It has the greatest effect with 82599 devices. Newer devices will =
respond to reads faster.

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_0EC29573-34CF-4539-8667-0C8BB8CA778C
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJVW2KMAAoJEDwO/+eO4+5u59MP/2fOMWi6ObrlnLrgE7MJI4hi
t9jHHJK8WiOe+VVm9EbAf+g4Oubpg74mcCHunlJEyAz3ZgKlLD/Q3d00oNYKGt89
aoANEC023ohkXhbIr7AU2/Yu0q6H+J5XsYZWVxN5A/tR/3heZromkVSi3+1ZVI4m
8gMt1n0BO5q92uMlXa3RuQbLlwFGwXKJcXEgm9Lcjq00MAlYggxA850lSNGYrzps
ZYaSUry4TdMVip7XYhSeUxwpL3X6wC07A0wmY0UGxMUF8pwDsbR4Ylopy2P9sOaL
fUBJyFHoudE9hRS/powQ2uGZ8FSuMhlRprp3b7WuMe4/aVsIB4tdfm0kIo8tMGw8
eYGDC6AYZxyhyBawBzodjQ6lJj563b+vo8TTNWBz+K1Ft1oQgEelQfKpIS/9Scdf
+KRpYku1FChzKFDdVhrH2NXen7b7uyJUvkY+HAr5m0lxhchcCPnkVCDiWjDNJAPH
FyN1mlCckhaTA8BUdvlcVDCYNoXPSRvExj0FM3A5kx7jsTNRET/9pAyaqbuizJRE
67JdIK6Dy1IN66KDIhh8hqzsApANBGc9LWPtihhcFimGm8w5NfHlfq9NlmKtvyxh
nABwd157/PKD0I+LhfGD9HdxBVnxrfsi5kbDsrdkq7Gq6/vZFvKE7wqxiFCl7Bt6
1zOYJ/unOm8i6ZCtCF54
=NYJd
-----END PGP SIGNATURE-----

--Apple-Mail=_0EC29573-34CF-4539-8667-0C8BB8CA778C--
