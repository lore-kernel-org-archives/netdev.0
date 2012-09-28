From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 28 Sep 2012 11:35:16 +1000
Message-ID: <20120928113516.165a26a1fc6974931d2425c2@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__28_Sep_2012_11_35_16_+1000_STtnfsH1kxyAkPH5"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__28_Sep_2012_11_35_16_+1000_STtnfsH1kxyAkPH5
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/l2tp/l2tp_netlink.c between commit 7f8436a1269e ("l2tp: fix return
value check") from the net tree and commit 15e473046cb6 ("netlink: Rename
pid to portid to avoid confusion") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/l2tp/l2tp_netlink.c
index 6f93635,6ec3f67..0000000
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@@ -78,10 -78,10 +78,10 @@@ static int l2tp_nl_cmd_noop(struct sk_b
  		goto out;
  	}
 =20
- 	hdr =3D genlmsg_put(msg, info->snd_pid, info->snd_seq,
+ 	hdr =3D genlmsg_put(msg, info->snd_portid, info->snd_seq,
  			  &l2tp_nl_family, 0, L2TP_CMD_NOOP);
 -	if (IS_ERR(hdr)) {
 -		ret =3D PTR_ERR(hdr);
 +	if (!hdr) {
 +		ret =3D -EMSGSIZE;
  		goto err_out;
  	}
 =20
@@@ -248,10 -248,10 +248,10 @@@ static int l2tp_nl_tunnel_send(struct s
  	struct l2tp_stats stats;
  	unsigned int start;
 =20
- 	hdr =3D genlmsg_put(skb, pid, seq, &l2tp_nl_family, flags,
+ 	hdr =3D genlmsg_put(skb, portid, seq, &l2tp_nl_family, flags,
  			  L2TP_CMD_TUNNEL_GET);
 -	if (IS_ERR(hdr))
 -		return PTR_ERR(hdr);
 +	if (!hdr)
 +		return -EMSGSIZE;
 =20
  	if (nla_put_u8(skb, L2TP_ATTR_PROTO_VERSION, tunnel->version) ||
  	    nla_put_u32(skb, L2TP_ATTR_CONN_ID, tunnel->tunnel_id) ||
@@@ -616,9 -616,9 +616,9 @@@ static int l2tp_nl_session_send(struct=20
 =20
  	sk =3D tunnel->sock;
 =20
- 	hdr =3D genlmsg_put(skb, pid, seq, &l2tp_nl_family, flags, L2TP_CMD_SESS=
ION_GET);
+ 	hdr =3D genlmsg_put(skb, portid, seq, &l2tp_nl_family, flags, L2TP_CMD_S=
ESSION_GET);
 -	if (IS_ERR(hdr))
 -		return PTR_ERR(hdr);
 +	if (!hdr)
 +		return -EMSGSIZE;
 =20
  	if (nla_put_u32(skb, L2TP_ATTR_CONN_ID, tunnel->tunnel_id) ||
  	    nla_put_u32(skb, L2TP_ATTR_SESSION_ID, session->session_id) ||

--Signature=_Fri__28_Sep_2012_11_35_16_+1000_STtnfsH1kxyAkPH5
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQZP7UAAoJEECxmPOUX5FEMWcP/iwmWma/VHeQ8bSIvvcDxDNN
7P0na1YpU/aHDFhLjaHWs75I1ILhJSF2KiU0p+d9/rpUh/i3KTqDUAALLqSnLC4B
ntvy24NA+zQ2nMEPyH/v7glzwihBEV+7u5yDsjq1LmPqvO9lMM0nESn6xkSG71SB
3X8GYpTXlWI4YuIcRpxPYVQ41fJTLB7iOvzmcuhLU+cqBLUUWpl3c9ofmuBfqcop
tZuTUWL1ydqbIQlGfGlO66O7CD0Uxc/jL//BJNwDS1nj6j62sX7hU/Sbbwkc0Vny
XfOE97tTtwj9a88B1CbwqcISkvGkHx4tp/9ueVEft7eVGdorxaqo6OuRp3LWMGs5
7QHKnAzQWucr5Hd2OgnBJGDcrb8uySxMrPOrhw0uerBQG7Lt8l0S+yCszJ0OsfNn
TuDpVw2C58fjyu/AuqK+YtEC9bOV/CthyYIvt1B50RhOUEQHDYiSX2kPliwLBjBT
a7BcGadjF5T4Xk9jMVx4bOdZjTANnNIE3tHbiTSfqaO5KkDzMn/tZH3m8pWHJCB7
iYe/gTcWELYnvj/hgGDSvg9rUYX+kfIHQ6ocVC6lsVpubZxa4fDxNzZYYPH5NBP6
QIrBvk96jxAW/bSD0urcOkEZqYLIvC5TLDHRcwzCMPYs+0Q5aLmu55xUJxJiYFCT
Ku6LYdRBpttCuVxfGkiR
=c8Ps
-----END PGP SIGNATURE-----

--Signature=_Fri__28_Sep_2012_11_35_16_+1000_STtnfsH1kxyAkPH5--
