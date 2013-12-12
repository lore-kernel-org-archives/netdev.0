From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 12 Dec 2013 11:15:39 +1100
Message-ID: <20131212111539.cff1b2efe934c5cd7abbb822@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__12_Dec_2013_11_15_39_+1100_RfUABrleJpPNKvOn"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jason Wang <jasowang@redhat.com>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__12_Dec_2013_11_15_39_+1100_RfUABrleJpPNKvOn
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/macvtap.c between commit ce232ce01d61 ("macvtap: signal
truncated packets") from the net tree and commit 55ec8e25cd97 ("macvtap:
remove unused parameter in macvtap_do_read()") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/macvtap.c
index 2a89da080317,4a34bcb6549f..000000000000
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@@ -819,12 -813,13 +815,12 @@@ static ssize_t macvtap_put_user(struct=20
  	}
 =20
  	ret =3D skb_copy_datagram_const_iovec(skb, vlan_offset, iv, copied, len);
 -	copied +=3D len;
 =20
  done:
 -	return ret ? ret : copied;
 +	return ret ? ret : total;
  }
 =20
- static ssize_t macvtap_do_read(struct macvtap_queue *q, struct kiocb *ioc=
b,
+ static ssize_t macvtap_do_read(struct macvtap_queue *q,
  			       const struct iovec *iv, unsigned long len,
  			       int noblock)
  {
@@@ -875,8 -870,8 +871,8 @@@ static ssize_t macvtap_aio_read(struct=20
  		goto out;
  	}
 =20
- 	ret =3D macvtap_do_read(q, iocb, iv, len, file->f_flags & O_NONBLOCK);
+ 	ret =3D macvtap_do_read(q, iv, len, file->f_flags & O_NONBLOCK);
 -	ret =3D min_t(ssize_t, ret, len); /* XXX copied from tun.c. Why? */
 +	ret =3D min_t(ssize_t, ret, len);
  	if (ret > 0)
  		iocb->ki_pos =3D ret;
  out:

--Signature=_Thu__12_Dec_2013_11_15_39_+1100_RfUABrleJpPNKvOn
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSqQAvAAoJEMDTa8Ir7ZwVaQEP/jd7CyfJpxt4SVf9PkXubh51
C2vHhwMq+fa5Xe7hsVohFXaK0bErgWGBdMfJm3e5TI7yguKY1v+uIEyAxQQl2nQG
t74LRt7wio1F2kGp2O8K61pzScEyNU6EXZuzh/hLvXEbKufdceqVjdhe1P2ZZ9UX
9S1xA760jPYwGVFb+H5IZoWjbt6mkvP6lRNcnkoXHX4CSl58bMfvsvocQ3oiK19x
u/I0FbUmxnibweFfALK0ouJmSWej3xcclKKQ7dKaZLxmMTwa0fF5jdi0udukQWiJ
C2av5GiHUbltQmqhHKTbdzmrLBvtOZ/DuBu8sYZbWCvN7GURJsZT/Yz2PKNyO7AL
puOnO0aRHGNrqpbzR7At+m/e7kT7Ni9zMWVwxLnbViV5tfAw8aYO3cMkpotOY+ip
QoxaJekwNOazXQwJq5bA3lpGW9Yaag5JQ9QBIQum/uLScPOAN0PnQOiUkH6sy3Sj
LlicY10+U334A9b63Cpji1cEthr1wnlwHARdiCSp31Um7Wz/J0KA+c+3/Y5NoSQH
ne4fc9cvEQy2SkS+N0ZtOJxfLAEJlmu00eW2lbRul0uFOHxIMRFI6ZPhFdu/haY5
CGJSwiU0eppwNOGxYwkp2UKGKC4c0QosPHMyQYQcF0uqDorl+AqtZDDDvwDo97MH
42AFm8hrmNDh/mgj1j/3
=oEjt
-----END PGP SIGNATURE-----

--Signature=_Thu__12_Dec_2013_11_15_39_+1100_RfUABrleJpPNKvOn--
