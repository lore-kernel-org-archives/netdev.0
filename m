From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Thu, 12 Jun 2014 12:14:05 +1000
Message-ID: <20140612121405.29828461@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/mutqB3Sa9oEFTbX8sn6949V"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Linus =?UTF-8?B?TMO8c3Npbmc=?= <linus.luessing@web.de>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/mutqB3Sa9oEFTbX8sn6949V
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (powerpc
ppc64_defconfig) failed like this:

net/bridge/br_multicast.c: In function 'br_multicast_has_querier_adjacent':
net/bridge/br_multicast.c:2248:25: error: 'struct net_bridge' has no member=
 named 'ip6_other_query'
   if (!timer_pending(&br->ip6_other_query.timer) ||
                         ^
In file included from include/linux/idr.h:18:0,
                 from include/linux/kernfs.h:14,
                 from include/linux/sysfs.h:15,
                 from include/linux/kobject.h:21,
                 from include/linux/device.h:17,
                 from include/linux/dma-mapping.h:5,
                 from arch/powerpc/include/asm/machdep.h:14,
                 from arch/powerpc/include/asm/archrandom.h:6,
                 from include/linux/random.h:81,
                 from include/linux/net.h:22,
                 from include/linux/skbuff.h:27,
                 from include/linux/if_ether.h:23,
                 from net/bridge/br_multicast.c:15:
net/bridge/br_multicast.c:2249:25: error: 'struct net_bridge' has no member=
 named 'ip6_querier'
       rcu_dereference(br->ip6_querier.port) =3D=3D port)
                         ^
net/bridge/br_multicast.c:2249:25: error: 'struct net_bridge' has no member=
 named 'ip6_querier'
       rcu_dereference(br->ip6_querier.port) =3D=3D port)
                         ^
In file included from include/linux/err.h:4:0,
                 from net/bridge/br_multicast.c:13:
net/bridge/br_multicast.c:2249:25: error: 'struct net_bridge' has no member=
 named 'ip6_querier'
       rcu_dereference(br->ip6_querier.port) =3D=3D port)
                         ^
net/bridge/br_multicast.c:2249:25: error: 'struct net_bridge' has no member=
 named 'ip6_querier'
       rcu_dereference(br->ip6_querier.port) =3D=3D port)
                         ^
In file included from include/linux/idr.h:18:0,
                 from include/linux/kernfs.h:14,
                 from include/linux/sysfs.h:15,
                 from include/linux/kobject.h:21,
                 from include/linux/device.h:17,
                 from include/linux/dma-mapping.h:5,
                 from arch/powerpc/include/asm/machdep.h:14,
                 from arch/powerpc/include/asm/archrandom.h:6,
                 from include/linux/random.h:81,
                 from include/linux/net.h:22,
                 from include/linux/skbuff.h:27,
                 from include/linux/if_ether.h:23,
                 from net/bridge/br_multicast.c:15:
net/bridge/br_multicast.c:2249:25: error: 'struct net_bridge' has no member=
 named 'ip6_querier'
       rcu_dereference(br->ip6_querier.port) =3D=3D port)
                         ^

Caused by commit 2cd4143192e8 ("bridge: memorize and export selected
IGMP/MLD querier port").  This build has CONFIG_IPV6 not set.

I have reverted that commit for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/mutqB3Sa9oEFTbX8sn6949V
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJTmQzyAAoJEMDTa8Ir7ZwVoasP/18eb3g7lmiVBUH2WNK8HXbU
sl9xTFefW5j0nTV1ZdmgTuukxoyj9LpykAywo+e90MXk44ABXpTTh7vTUO5jTf9D
v7ivmd3illypy//r49iSa5KMbqYVmSZAOy9yELdxiwAlppWnz5tlkyHwQ+H0v/z0
4YIKYj1lcXdKR1jlnyJCRYHAHgM5DuYUSMtrQafI1DcgYdC1GxHFUU4lQF20P+8k
Jy5igjz6PB6GdahaftXEE/jSOjdhnebP4F0tC+OkT/isLl26oJnSMcqvGLGmbWod
ZvUo4e1gCUSG/Nd0dA3vhWYTTqgCcDa/a27hLysVZ7Sk9NyzJLg4b498FJbris3S
1T/+aL/0vsSIirjj/LXGKeQC57jaBU5fZGbAWLaE0mvKJxofLQL9tACZkuvEEylg
NORS8K23IxsIdnPmwSMCE5oFvX0knUAXUakrKv7gT0KUeUmvmGxWBifYHcQ1jhnk
J06VoR83vkxOcQXq9CgTrGjbbTwgooxqNdvH+KHyrkoYTbq7osivFKaFK4mTiyI7
dm0mFWfWyXnGH9y1z/2A7w7DHUM1+mOd2MKHj0eqXHKIPlHBPFbSLMlGFo2rArh6
woxPVBefrKair5oQwxKESjW4gQvcwQapsb/RVyxC2U+bZYYKEBoFYNnNMdRv+nxw
dUS7exuBWlsMCXssRGOq
=LMOH
-----END PGP SIGNATURE-----

--Sig_/mutqB3Sa9oEFTbX8sn6949V--
