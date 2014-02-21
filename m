From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 21 Feb 2014 13:49:33 +1100
Message-ID: <20140221134933.ccf25d5023ecb3c48ee3cf7d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__21_Feb_2014_13_49_33_+1100_f.MgZ7l9YvWUHzj3"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	WANG Cong <xiyou.wangcong@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__21_Feb_2014_13_49_33_+1100_f.MgZ7l9YvWUHzj3
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/ipv6/sit.c between commit cf71d2bc0b8a ("sit: fix panic with route
cache in ip tunnels") from the  tree and commit 1c213bd24ad0 ("net:
introduce netdev_alloc_pcpu_stats() for drivers") from the net-next tree.

I fixed it up (I think ... see below) and can carry the fix as necessary
(no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/ipv6/sit.c
index b4d74c86586c,958027be0e94..000000000000
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@@ -1376,18 -1368,6 +1375,12 @@@ static int ipip6_tunnel_init(struct net
  	if (!dev->tstats)
  		return -ENOMEM;
 =20
- 	for_each_possible_cpu(i) {
- 		struct pcpu_sw_netstats *ipip6_tunnel_stats;
- 		ipip6_tunnel_stats =3D per_cpu_ptr(dev->tstats, i);
- 		u64_stats_init(&ipip6_tunnel_stats->syncp);
- 	}
-=20
 +	tunnel->dst_cache =3D alloc_percpu(struct ip_tunnel_dst);
 +	if (!tunnel->dst_cache) {
 +		free_percpu(dev->tstats);
 +		return -ENOMEM;
 +	}
 +
  	return 0;
  }
 =20
@@@ -1412,18 -1391,6 +1404,12 @@@ static int __net_init ipip6_fb_tunnel_i
  	if (!dev->tstats)
  		return -ENOMEM;
 =20
- 	for_each_possible_cpu(i) {
- 		struct pcpu_sw_netstats *ipip6_fb_stats;
- 		ipip6_fb_stats =3D per_cpu_ptr(dev->tstats, i);
- 		u64_stats_init(&ipip6_fb_stats->syncp);
- 	}
-=20
 +	tunnel->dst_cache =3D alloc_percpu(struct ip_tunnel_dst);
 +	if (!tunnel->dst_cache) {
 +		free_percpu(dev->tstats);
 +		return -ENOMEM;
 +	}
 +
  	dev_hold(dev);
  	rcu_assign_pointer(sitn->tunnels_wc[0], tunnel);
  	return 0;

--Signature=_Fri__21_Feb_2014_13_49_33_+1100_f.MgZ7l9YvWUHzj3
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIbBAEBCAAGBQJTBr7BAAoJEMDTa8Ir7ZwVSmMP+NsNzBm9WT/xBA+QYW1hOMIk
FZC4p0vxTu2IE9yFuRkEW+6E3mE08j2uRhI4uQn3vKXaguEGh6o/qJNXi0PL9NxU
RbxufCZTbolKvSLNdYrzSRHbaCrWL8YbXAhmuYoXgClm5IxC2MuIScyitDoZGlNs
DJr4Q3foSRQOTH8j3ScgSA+YKe4U7KIdFTdraWjYu36Mzcv7/1t2jrvzn+l/I+/w
1gzVpL8MYwX7J3NabqDqtM6FZfLbO/ZGQ2bhNADMUZcW2OskIeMU2sfOXwPNapnW
MqrzzWD8FdvPN47atMzz/VzqJsf432WtT5vSg1NHue7lmwYF13J396XILIrE1aox
cCOGMzgjz1qczWSOLMO/0bGvuUQAxGPFRdNWb5XRIvePQw+CUlLAHYdcVW2T6wsG
26kvCrE3gsrWGtUB1bFNd3L3hjmXdJR7LQC3+vcJcfrYvKP2M11Z+fLpQzFjUOzG
B+OYw5VbpF0/2OpzVoV8uSBJA/lxRvlAIvsmnyHGKPF7010NX2PiW9nSZNGhKI3S
/Cp2hUAvAyIDcDM4QfN54neGEvDxHc0A1fhRrO95qjcga53zQAvST5WY93FuWycF
J3rGrVXtEBOJ0RMW0BSN6m0sPnDOHRX2/dmvTqqjBy3Q29BnduirIzz513gbNp1Q
MLvUCsthQsbXhpDem08=
=LCl/
-----END PGP SIGNATURE-----

--Signature=_Fri__21_Feb_2014_13_49_33_+1100_f.MgZ7l9YvWUHzj3--
