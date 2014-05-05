From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 5 May 2014 12:10:59 +1000
Message-ID: <20140505121059.3bfeee816db3c39945734897@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__5_May_2014_12_10_59_+1000_e/250.re52uThTYt"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	=?UTF-8?B?IlN0w6lwaGFuZSBH?= =?UTF-8?B?cmFiZXIi?=
	<stgraber@ubuntu.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__5_May_2014_12_10_59_+1000_e/250.re52uThTYt
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got conflicts in
net/sched/sch_api.c and net/sched/cls_api.c between commit 90f62cf30a78
("net: Use netlink_ns_capable to verify the permisions of netlink
messages") from the net tree and commit 4e8bbb819d15 ("net: Allow tc
changes in user namespaces") from the net-next tree.

I fixed it up (hopefully, see below) and can carry the fix as necessary
(no action is required).

--=20
Cheers,
Stephen Rothwell <sfr@canb.auug.org.au>

diff --cc net/sched/cls_api.c
index bdbdb1a7920a,1a4a20267787..000000000000
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@@ -134,7 -134,8 +134,8 @@@ static int tc_ctl_tfilter(struct sk_buf
  	int err;
  	int tp_created =3D 0;
 =20
- 	if ((n->nlmsg_type !=3D RTM_GETTFILTER) && !netlink_capable(skb, CAP_NET=
_ADMIN))
+ 	if ((n->nlmsg_type !=3D RTM_GETTFILTER) &&
 -	    !ns_capable(net->user_ns, CAP_NET_ADMIN))
++	    !netlink_ns_capable(skb, net->user_ns, CAP_NET_ADMIN))
  		return -EPERM;
 =20
  replay:
diff --cc net/sched/sch_api.c
index 400769014bbd,86f8edfd6b8a..000000000000
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@@ -1084,7 -1084,8 +1084,8 @@@ static int tc_get_qdisc(struct sk_buff=20
  	struct Qdisc *p =3D NULL;
  	int err;
 =20
- 	if ((n->nlmsg_type !=3D RTM_GETQDISC) && !netlink_capable(skb, CAP_NET_A=
DMIN))
+ 	if ((n->nlmsg_type !=3D RTM_GETQDISC) &&
 -	    !ns_capable(net->user_ns, CAP_NET_ADMIN))
++	    !netlink_ns_capable(skb, net->user_ns, CAP_NET_ADMIN))
  		return -EPERM;
 =20
  	err =3D nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL);
@@@ -1151,7 -1152,7 +1152,7 @@@ static int tc_modify_qdisc(struct sk_bu
  	struct Qdisc *q, *p;
  	int err;
 =20
- 	if (!netlink_capable(skb, CAP_NET_ADMIN))
 -	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
++	if (!netlink_ns_capable(skb, net->user_ns, CAP_NET_ADMIN))
  		return -EPERM;
 =20
  replay:
@@@ -1490,7 -1491,8 +1491,8 @@@ static int tc_ctl_tclass(struct sk_buf
  	u32 qid;
  	int err;
 =20
- 	if ((n->nlmsg_type !=3D RTM_GETTCLASS) && !netlink_capable(skb, CAP_NET_=
ADMIN))
+ 	if ((n->nlmsg_type !=3D RTM_GETTCLASS) &&
 -	    !ns_capable(net->user_ns, CAP_NET_ADMIN))
++	    !netlink_ns_capable(skb, net->user_ns, CAP_NET_ADMIN))
  		return -EPERM;
 =20
  	err =3D nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL);

--Signature=_Mon__5_May_2014_12_10_59_+1000_e/250.re52uThTYt
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTZvM3AAoJEMDTa8Ir7ZwV8CAP/ArqZdNL62aJbSzEv3rAvPuT
ttounYrLSki9wsiP405XfCYYeXoRnGvLe3wxsP430W71WN+j/5IxO0Bb0rNfNNgb
MXvRyLP1ahOsqipoD9Tz6Og4H4FCpPXQXtXY8S19uGbg5h6MgbuC+PSwWeeazK70
3nN4S8K7pAS1s5p1QHJp3E/R5q2fEaXIbEgNhD5KcOVU8dbYCoQfgp+PxHwBfaR+
07c4sdR6T0S40obuOAh/FccpOHFNzkK9WrC8QPQlVpv4iKmPcgYCK00nAMGWa3zy
ohwlDLUKFAK/jbpv3fw9anbMDymlBvpSA9H/MBTzs6U1m5lR4gs8TD5eAhydhJEN
V5iUTQ7nafQABdpMqZ4/c4tPHA7mhdZtGoYIJot9osyOKVhDBrwfVpYzZIDWIePi
4mhkJIj/zHSxt/UDuBkI2/0D2EfvREYSt32ZnrpdxiyXr0iEoXLM338XPp2T7YJ+
uQ/YJzeXjCYricUMB0kmhn27+O2cZUwl09s2TYPpVG68QwzQwQPkSlAMDdra47Ev
4N4hRbe8JCXnAl/iZguBvf08yUeTAgWrgrkBaZrAlKuc905JoSo2HmjAEXs1jb8n
GR4N9pCzu+0IlhN4Jj7Xsxk1lte6w94+Bpt2vCChnsx3UBflwcJSt+c8yi++WL+e
vinmpifQp7M0LyNld7jj
=smVQ
-----END PGP SIGNATURE-----

--Signature=_Mon__5_May_2014_12_10_59_+1000_e/250.re52uThTYt--
