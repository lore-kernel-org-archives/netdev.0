From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the tip tree with the net-next tree
Date: Mon, 5 May 2014 14:29:34 +1000
Message-ID: <20140505142934.4d732ab3e809850b426fce3d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__5_May_2014_14_29_34_+1000_pDT=pzXV7VKODGji"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Zijlstra <peterz@infradead.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__5_May_2014_14_29_34_+1000_pDT=pzXV7VKODGji
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the tip tree got a conflict in
net/ipv4/tcp_output.c between commit e114a710aa50 ("tcp: fix cwnd limited
checking to improve congestion control") from the  tree and commit
4e857c58efeb ("arch: Mass conversion of smp_mb__*()") from the tip tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/ipv4/tcp_output.c
index 694711a140d4,366cf06587b8..000000000000
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@@ -1946,18 -1930,10 +1946,16 @@@ static bool tcp_write_xmit(struct sock=20
  			/* It is possible TX completion already happened
  			 * before we set TSQ_THROTTLED, so we must
  			 * test again the condition.
- 			 * We abuse smp_mb__after_clear_bit() because
- 			 * there is no smp_mb__after_set_bit() yet
  			 */
- 			smp_mb__after_clear_bit();
+ 			smp_mb__after_atomic();
 -			if (atomic_read(&sk->sk_wmem_alloc) > limit)
 +			if (atomic_read(&sk->sk_wmem_alloc) > limit) {
 +				u32 unsent_bytes;
 +
 +compute_unsent_segs:
 +				unsent_bytes =3D tp->write_seq - tp->snd_nxt;
 +				unsent_segs =3D DIV_ROUND_UP(unsent_bytes, mss_now);
  				break;
 +			}
  		}
 =20
  		limit =3D mss_now;

--Signature=_Mon__5_May_2014_14_29_34_+1000_pDT=pzXV7VKODGji
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTZxO3AAoJEMDTa8Ir7ZwVussP+wZ2M7RclqjNPcx4HqnSitMf
z+OdogQvRBAz27NfhWWs2ekr9QPUgurNwg3ufmiUC3nSPtV4emSHcbTABGf1Zkuo
TTajnam40xxuSIFsRA7JNhxyW56mGWqk7Vzc/Q9ru4DsyRIk5gSC7TK6Ufe4vqnm
X1f6pCGVuViLc5Zc6N7bNnr/VeeIXSTiIMAroG9IB6aPii6RdVLqYrbECoMkkP19
O0gO1z3UDR2yNIRgn438c8dKqR2LVN2MvmAwOpncheNCmI9z43LKvaa3ZgFd5oN4
JbR3KBFar86wFJCfjfx1x8Dr+EZlqh0MY6/N0IC9b1ytbZdi9/AI0omtleqi93/S
PM7gYs/BFlP0LSiQgTJ2dCqi8pi65v5si0CL7yKnG5yr7K+cwgaSm686+NNWnHIQ
7a8jJ3FbtHnUXskL+IogC6B67se3QUdXTXvw89//GzUJeqVgNcVR7H4L8CDssiZJ
Y/IFLUbvThkgJcVoUIYe2c+dfXZJv4qp8pobWUIBq6SXMt5lWQFZP1RI4Eenajqh
dMutFs2pHanc2rjFzgqEU/9lNqZL8II0MdTFlDoDyb2F1fIZThFp7Y8G6Sc1f/uS
fvhcCCNzZThjayxsdxpFw6DRNtG6WFuCgmwc6BamacgCTbAxYmEZhVMYLcHcGG6A
TSDyCo7zcZYqI6/VmT0j
=Mxms
-----END PGP SIGNATURE-----

--Signature=_Mon__5_May_2014_14_29_34_+1000_pDT=pzXV7VKODGji--
