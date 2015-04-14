From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the ftrace tree with the net-next tree
Date: Tue, 14 Apr 2015 15:16:24 +1000
Message-ID: <20150414151624.044c9a41@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/bmHVqm62IzyQn0T65ypHxHZ"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Felix Fietkau <nbd@openwrt.org>
To: Steven Rostedt <rostedt@goodmis.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/bmHVqm62IzyQn0T65ypHxHZ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Steven,

Today's linux-next merge of the ftrace tree got a conflict in
net/mac80211/trace.h between commit ba8c3d6f16a1 ("mac80211: add an
intermediate software queue implementation") from the net-next tree and
commit 1bc1e4d048d3 ("mac80211: Move message tracepoints to their own
header") from the ftrace tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/mac80211/trace.h
index 790bd45081c4,755a5388dbca..000000000000
--- a/net/mac80211/trace.h
+++ b/net/mac80211/trace.h
@@@ -2312,75 -2312,6 +2312,37 @@@ TRACE_EVENT(drv_tdls_recv_channel_switc
  	)
  );
 =20
 +TRACE_EVENT(drv_wake_tx_queue,
 +	TP_PROTO(struct ieee80211_local *local,
 +		 struct ieee80211_sub_if_data *sdata,
 +		 struct txq_info *txq),
 +
 +	TP_ARGS(local, sdata, txq),
 +
 +	TP_STRUCT__entry(
 +		LOCAL_ENTRY
 +		VIF_ENTRY
 +		STA_ENTRY
 +		__field(u8, ac)
 +		__field(u8, tid)
 +	),
 +
 +	TP_fast_assign(
 +		struct ieee80211_sta *sta =3D txq->txq.sta;
 +
 +		LOCAL_ASSIGN;
 +		VIF_ASSIGN;
 +		STA_ASSIGN;
 +		__entry->ac =3D txq->txq.ac;
 +		__entry->tid =3D txq->txq.tid;
 +	),
 +
 +	TP_printk(
 +		LOCAL_PR_FMT  VIF_PR_FMT  STA_PR_FMT " ac:%d tid:%d",
 +		LOCAL_PR_ARG, VIF_PR_ARG, STA_PR_ARG, __entry->ac, __entry->tid
 +	)
 +);
 +
- #ifdef CONFIG_MAC80211_MESSAGE_TRACING
- #undef TRACE_SYSTEM
- #define TRACE_SYSTEM mac80211_msg
-=20
- #define MAX_MSG_LEN	100
-=20
- DECLARE_EVENT_CLASS(mac80211_msg_event,
- 	TP_PROTO(struct va_format *vaf),
-=20
- 	TP_ARGS(vaf),
-=20
- 	TP_STRUCT__entry(
- 		__dynamic_array(char, msg, MAX_MSG_LEN)
- 	),
-=20
- 	TP_fast_assign(
- 		WARN_ON_ONCE(vsnprintf(__get_dynamic_array(msg),
- 				       MAX_MSG_LEN, vaf->fmt,
- 				       *vaf->va) >=3D MAX_MSG_LEN);
- 	),
-=20
- 	TP_printk("%s", __get_str(msg))
- );
-=20
- DEFINE_EVENT(mac80211_msg_event, mac80211_info,
- 	TP_PROTO(struct va_format *vaf),
- 	TP_ARGS(vaf)
- );
- DEFINE_EVENT(mac80211_msg_event, mac80211_dbg,
- 	TP_PROTO(struct va_format *vaf),
- 	TP_ARGS(vaf)
- );
- DEFINE_EVENT(mac80211_msg_event, mac80211_err,
- 	TP_PROTO(struct va_format *vaf),
- 	TP_ARGS(vaf)
- );
- #endif
-=20
  #endif /* !__MAC80211_DRIVER_TRACE || TRACE_HEADER_MULTI_READ */
 =20
  #undef TRACE_INCLUDE_PATH

--Sig_/bmHVqm62IzyQn0T65ypHxHZ
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVLKKvAAoJEMDTa8Ir7ZwV3J0QAJJtLmvoU/sRLFbZBTGHoXa0
Apbu9fhKjL1p9RNdXd2ptEV+/MX8tgw4widv/HZ/bsZ6s5lJNUPKP1nNorbgsffh
JdLuGdRtOYTEHZS9E1jAeBVucr7miq9xBxwSqCkVNLoaNGWXXrQNRrP8EK7aUEj2
FW8lYw9r2+v4EhUBqRnyqB81twIcF8YwnQm/yuIguWJJb5tXsNK9jv5BEcf5Zegg
u4gMbsN9YEtAdthktHr1spFZSmp17HSz4ho3zImPlJfL2+zS36YEUmpGvqjQvQlZ
VJLWf2NRJsYzn5vwM7UtAIrHK29kT3IO4y+WdPSx4qhn5gJOk3ZJ4ITu4VQ2083S
GbhV/ZDfehXOJZ6a7XHVsAhrJY6CH6i+DuwE3qc6wJ6iIl/SLMxN9yYCRgEsXNTI
yApgkUxPxdqemOOxIuSzqQTVr3YCjZpsJAOkkZi8y1GeLQsBITys0waruh62XTcl
MtDUpT6lPcH6rkkbfEOO7A5We6guPrlDuxu15Px8NTQndCIDNOv+2D3z8IFu3XV/
kjCG4UsUjAmOpk4pV/mnd+E4Mv7Ql7nYh4QsL4LMQPf4F4/NR0aa5Hly0ERTmyra
S3MKgY68iynd6/X94QbcG9ZGJ87WOdu9wLDOIXyh+5buGABMt4HDdmFr0ajgMHQb
DfniHIFqLjT0bbpPE7Iq
=5A88
-----END PGP SIGNATURE-----

--Sig_/bmHVqm62IzyQn0T65ypHxHZ--
