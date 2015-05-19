From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH] pci: Limit VPD reads for all Intel
 Ethernet devices
Date: Tue, 19 May 2015 21:04:17 +0000
Message-ID: <DA06AAB6-CE9B-4A27-B60D-8F55BB52A063@intel.com>
References: <20150519000042.56109.69779.stgit@mdrustad-wks.jf.intel.com>
 <555B5CBF.1090902@redhat.com>
 <4AD84211-965C-4F0B-A7F4-3E6CCE6567E3@intel.com>
 <555B77E5.5060006@redhat.com>
 <99014381-25AB-416D-8E09-C431B5CD5A6C@intel.com>
 <555B9F74.3040004@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_8F5E4C64-3D39-4CDA-8005-FF62D6AE20AE";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "bhelgaas@google.com" <bhelgaas@google.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:48277 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751209AbbESVJP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2015 17:09:15 -0400
In-Reply-To: <555B9F74.3040004@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_8F5E4C64-3D39-4CDA-8005-FF62D6AE20AE
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252

> On May 19, 2015, at 1:39 PM, Alexander Duyck =
<alexander.h.duyck@redhat.com> wrote:
>=20
> So how does this improve boot time anyway?  The original patch =
description said this improved boot time and reduced memory usage but I =
have yet to find where any of those gains would actually occur.  If you =
can point me in that direction I might have a better idea of the =
motivations behind this.

I have to admit that you won't find them in the kernel, but systems that =
read VPD in the course of starting up will benefit by not reading lots =
of useless stuff so slowly. At least those reads will be slow on any =
device that reads VPD from slow hardware. Since the kernel would never =
perform any of those reads itself, in isolation the kernel has no =
benefit. However the system gets a benefit.

I can delete the reference to a memory benefit, since it would be a =
fleeting benefit at most and not a kernel memory footprint issue.

This is not a big deal for me. If you don't see the value, drop it. Some =
people are interested in speeding up boot. Apparently VPD is now being =
accessed in parallel by user space as a result of such work, exposing =
the problem addressed in the other patch. I saw this opportunity while =
trying to resolve that issue. If it isn't worth it, drop it.

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_8F5E4C64-3D39-4CDA-8005-FF62D6AE20AE
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJVW6VQAAoJEDwO/+eO4+5uSecP/i/5S1pHbZCSVv12IU+rqy81
Cba1llswE9syw99KaWsO8eILvBshgAxw+sDAwxs/46nVfgtleuBGRmF3yaGqUpFZ
71B8OqMsgYrjddd1yHsKkWaqDJmZUtjS7+/vgWLVjo9RepRlOXl0xjkTmtW9mAXT
mUSjuu8oxaU6lAYjBEPcN7DDPJ087ul1Ubat6Mo6KoJ76CwX5KhQUp+fsql6chBy
delxa1DiM/IgWqeE7ZqGW9gYNeH2swCHdhsZWDGrMJBSs1Qi1g4OYxOOlek9RzTZ
HxMkb3wU1ny7WB8HQW1XPAnLue3+Yz8XXXpDKdVPmy9cjBVgq/SRQ44rwJulxlRW
9wusUfY3P2aqeY8hxtpncaHT/iU50NVodgT/x/06vEoIpfvrszGhKRBPY3ieaSqm
XQo7gmQTniRpVADAEzH56Hcf0VoBQM4lHBisjbHGD257iXfZYzpiDHrdS33QSoXM
wfHP3fqQh9qNAE6ETGDmDVXBSQeO0o1zQyT9IabNg01nss4UNkrq1elx3Ybf0WTy
H+PglzOUNu/0cYFLE9au7FMWq625AFgja02HpInem16ko7TRMJtqqaUkcHlcuI2J
D9YlEr2Rfjkcyb2jpS2lrn08Qpluwz2P2gNkEIg6TpCDowLAO0mcLKeEpDjYoIgg
lnmk4D9PpU/iuj46UWaf
=7M5Q
-----END PGP SIGNATURE-----

--Apple-Mail=_8F5E4C64-3D39-4CDA-8005-FF62D6AE20AE--
