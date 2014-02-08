From: Richard Yao <ryao@gentoo.org>
Subject: Re: [PATCH 1/2] mm/vmalloc: export is_vmalloc_or_module_addr
Date: Sat, 08 Feb 2014 15:44:28 -0500
Message-ID: <52F6972C.2030307@gentoo.org>
References: <1391886730-19667-1-git-send-email-ryao@gentoo.org>	<1391886730-19667-2-git-send-email-ryao@gentoo.org>	<CA+55aFx8TzOnW9xPFA4Ox-yFiSUo=cEqeQUmgw_JWjDNEZep8Q@mail.gmail.com>	<52F68C67.6050606@gentoo.org> <CA+55aFw2BGS-sPYM1xkO7MfZ_-u=7nF4RYFmoCM99rkL=PxvpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="ipcOiJN8fLMHosC4i2C2fA4nKsBt7GX35"
Cc: Mel Gorman <mgorman@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Rik van Riel <riel@redhat.com>,
	Eric Van Hensbergen <ericvh@gmail.com>,
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
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFw2BGS-sPYM1xkO7MfZ_-u=7nF4RYFmoCM99rkL=PxvpA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--ipcOiJN8fLMHosC4i2C2fA4nKsBt7GX35
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 02/08/2014 03:06 PM, Linus Torvalds wrote:
> On Sat, Feb 8, 2014 at 11:58 AM, Richard Yao <ryao@gentoo.org> wrote:
>>
>> My apologies for that. Here is the backtrace:
>>
>> [<ffffffff814878ce>] p9_virtio_zc_request+0x45e/0x510
>> [<ffffffff814814ed>] p9_client_zc_rpc.constprop.16+0xfd/0x4f0
>> [<ffffffff814839dd>] p9_client_read+0x15d/0x240
>> [<ffffffff811c8440>] v9fs_fid_readn+0x50/0xa0
>> [<ffffffff811c84a0>] v9fs_file_readn+0x10/0x20
>> [<ffffffff811c84e7>] v9fs_file_read+0x37/0x70
>> [<ffffffff8114e3fb>] vfs_read+0x9b/0x160
>> [<ffffffff81153571>] kernel_read+0x41/0x60
>> [<ffffffff810c83ab>] copy_module_from_fd.isra.34+0xfb/0x180
>=20
> So copy_module_from_fd() does read into a vmalloc'ed buffer (which
> isn't pretty, but at least it's not like using some statically
> allocated module data), but that's a regular vmalloc() afaik.
>=20
> So I don't see the need for "is_vmalloc_or_module_addr()". The regular
> "is_vmalloc_addr()" should be fine, and *is* usable from modules (it's
> inline, not exported, but it comes to the same thing wrt module use),
> exactly because we have traditionally allowed vmalloc'ed memory to be
> used.
>=20
> So is there some reason why it's not just using that simpler function?

My first instinct was to use "is_vmalloc_addr()" as you suggest.
However, is_vmalloc_addr() only applies to the vmalloc region. While all
architectures load kernel modules into virtual memory (to my knowledge),
some architectures do not load them into the vmalloc region.
is_vmalloc_or_module_addr() contains a comment that clearly states this:

int is_vmalloc_or_module_addr(const void *x)
{
        /*
         * ARM, x86-64 and sparc64 put modules in a special place,
         * and fall back on vmalloc() if that fails. Others
         * just put it in the vmalloc space.
         */
#if defined(CONFIG_MODULES) && defined(MODULES_VADDR)
        unsigned long addr =3D (unsigned long)x;
        if (addr >=3D MODULES_VADDR && addr < MODULES_END)
                return 1;
#endif
        return is_vmalloc_addr(x);
}

My inspection of the actual code agreed with that comment (at least for
S390), so I decided against using "is_vmalloc_addr()" here.


--ipcOiJN8fLMHosC4i2C2fA4nKsBt7GX35
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBAgAGBQJS9pcvAAoJECDuEZm+6Exkx8oP/jNJEfG/Dt79FXed4VoTJeIR
kQBfXTo+lp8Fpi+M4Wl0/Wrp3kteJjqMbKl0/NknZHUoHUZLbzWtSHDUPciQAwgE
5J1eGQSkMRUbvTRKj0jDK9wFzDgqkuu/3QdyI/0NkB98dyWKJ6j7dcGVVmieeTnP
bxP2YUtUFgEinizBXFOMjyGTyQviFdL6dHHAKlqMyfqX25ohh5zEDqwX31icpIpq
vaXylBFTeGfU1fyAcG8DNaDhRHc2K0I5FseT7HQvWEX3BGqyZyuh6eT6l4MxIK9v
tPvpL/sG+VnY1YJ4kcpIuzSfyzTUQwtgzP09T2L1awOKkFOboeW0EM4OnJSoZf3Y
ND+3lLRaW8i8SjJyZYYtxXSDyo4uI+bAsIpppvyaC8mi4nKbDQx+VWEGvU+gONa1
wBzFvhOuDcsl6oOczEDrr0Fe0V2aKAwxw3STPu/xMDONLqkU4oDDn3HBCCqj3G1b
ivrQ0IQfBDuy0QGJksjdNaKw+KdbkLSS7t+4kdyTer8/me4bMYL1lpx/YIFtdf1x
78SBIJ12QXWKSECfjeE7MxuyL2dNOWdAF8rHKzY07Pjh3L10/HLxU36LSY0ohxSh
FOjUiKXEJ/1ko0LI4Olwv9Syk+oFRYq8tFzkSKEtU011PXAXni6NMxgDAekm54cC
Us1DPDQ5ZfsdHyVvdodF
=EwqI
-----END PGP SIGNATURE-----

--ipcOiJN8fLMHosC4i2C2fA4nKsBt7GX35--
