From: Richard Yao <ryao@gentoo.org>
Subject: Re: [PATCH 1/2] mm/vmalloc: export is_vmalloc_or_module_addr
Date: Sat, 08 Feb 2014 14:58:31 -0500
Message-ID: <52F68C67.6050606@gentoo.org>
References: <1391886730-19667-1-git-send-email-ryao@gentoo.org>	<1391886730-19667-2-git-send-email-ryao@gentoo.org> <CA+55aFx8TzOnW9xPFA4Ox-yFiSUo=cEqeQUmgw_JWjDNEZep8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="uqXPEAPdQrvLxNhn7sbaIrf5aaMv8rbWX"
Cc: Eric Van Hensbergen <ericvh@gmail.com>,
	Ron Minnich <rminnich@sandia.gov>,
	Latchesar Ionkov <lucho@ionkov.net>,
	"David S. Miller" <davem@davemloft.net>,
	V9FS Develooper Mailing List
	<v9fs-developer@lists.sourceforge.net>,
	Linux Netdev Mailing List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
	Will Deacon <will.deacon@arm.com>,
	Christopher Covington <cov@codeaurora.org>,
	Matthew Thode <mthode@mthode.org>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Mel Gorman <mgorman@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Rik van Riel <riel@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFx8TzOnW9xPFA4Ox-yFiSUo=cEqeQUmgw_JWjDNEZep8Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--uqXPEAPdQrvLxNhn7sbaIrf5aaMv8rbWX
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 02/08/2014 02:45 PM, Linus Torvalds wrote:
> On Sat, Feb 8, 2014 at 11:12 AM, Richard Yao <ryao@gentoo.org> wrote:
> And what's the backtrace that gets mentioned - but not quoted - for
> the horrible 9p crap? So that we can see who the guilty party is that
> thinks that it's somehow ok to pass module addresses off to other
> kernel users..

My apologies for that. Here is the backtrace:

[<ffffffff814878ce>] p9_virtio_zc_request+0x45e/0x510
[<ffffffff814814ed>] p9_client_zc_rpc.constprop.16+0xfd/0x4f0
[<ffffffff814839dd>] p9_client_read+0x15d/0x240
[<ffffffff811c8440>] v9fs_fid_readn+0x50/0xa0
[<ffffffff811c84a0>] v9fs_file_readn+0x10/0x20
[<ffffffff811c84e7>] v9fs_file_read+0x37/0x70
[<ffffffff8114e3fb>] vfs_read+0x9b/0x160
[<ffffffff81153571>] kernel_read+0x41/0x60
[<ffffffff810c83ab>] copy_module_from_fd.isra.34+0xfb/0x180
[<ffffffff810cc420>] SyS_finit_module+0x70/0xd0
[<ffffffff814a08fd>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

The addresses are being passed to permit zero-copy between the guest and
the host. You can see this in the original thread back from December,
which is from before I knew how to submit patches properly:

http://www.spinics.net/lists/linux-virtualization/msg21734.html

> Please let's just fix the real problem, don't add more horridness on
> top of it because somebody messed up earlier.

This code avoids a copy between QEMU's 9p server and a guest Linux
kernel. Without it, the 9p-virtio code must allocate additional buffers
into which QEMU will write the data and then copy from those buffers
into the actual kernel buffers. How would you like 9p-virtio to do this?


--uqXPEAPdQrvLxNhn7sbaIrf5aaMv8rbWX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBAgAGBQJS9oxsAAoJECDuEZm+6ExkICMQAKrHlHG25+z85pdHS9RGXwaj
Oblb2a5XZ1u7JIGsZbr1H5MiKBzeMKJn5+DwDjb/x4ZiC18KsllNDpXYVGJ2MAeV
VkQQjUeMS8/KtDdKARbrF3NI1CqIJNz8jhdLj4jbU3eOn1lIltdyESaCCg9EAnIH
yBSEcQ3M5fmwDumu1rZUonSwd5VamLkMcOorsPsXpeocskXLja4erjPHvD/gjl7/
1DbQFFnYctlmWTNQbj4K4swS+IwHHhON1P3FMCqH9XXEyq7vpoAUpuubYPJe4Rs3
NWIvd0LZ7N20Pa2Ygea1LBbyW2ikNz7Q8pCEr4O6H6fIBjVd5iAV2v3SoKv400UP
slvgumfXdNfEkQMWIeKBzjRJbYuDdeRRr1UfPR+cpqSvTK1MrLFIGz1zmSIcaaM3
J9IPMhyjasa6clqEQwPDalKKEBliblq8r9CAQDz6D+dx6/lYBE2+GkUjlzq5omxa
4vruYz81yEfMmy/nbyMoxCZEMRC0jkIoWUWquRqqtVY34wE6woDzpIZfx5THAJcz
87KGue07+kUxcN12JJGlI5THq0pHQJELhNdU2Mic51YvIlyCbESh9uAZ0ARg5uZJ
IOmfv3ILI9lWuzs98/XAAAyfAdMKU/CWaf/MCQ9SWlmUsRcbx3p57qs+Ax3qkyPZ
dbFyyhJFcYgiSGvrEa8w
=OkRJ
-----END PGP SIGNATURE-----

--uqXPEAPdQrvLxNhn7sbaIrf5aaMv8rbWX--
