From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the ftrace tree with the net-next tree
Date: Mon, 13 Apr 2015 17:52:24 +1000
Message-ID: <20150413175224.73a9baff@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/lg1+9uPQq9RrnrzOTsT_xUc"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>
To: Steven Rostedt <rostedt@goodmis.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/lg1+9uPQq9RrnrzOTsT_xUc
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Steven,

Today's linux-next merge of the ftrace tree got a conflict in
drivers/net/wireless/iwlwifi/iwl-devtrace.h between commit 7e1223b50089
("iwlwifi: mvm: new Alive / error table API") from the net-next tree
and commit c5ef935d01a2 ("iwlwifi: Move each system tracepoints to
their own header") from the ftrace tree.

I fixed it up (see patch below, since this code was moved to a new file)
and can carry the fix as necessary (no action is required).

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 13 Apr 2015 17:21:30 +1000
Subject: [PATCH] iwlwifi: mvm: fix up for tracing split

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/wireless/iwlwifi/iwl-devtrace-iwlwifi.h | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-devtrace-iwlwifi.h b/drivers/=
net/wireless/iwlwifi/iwl-devtrace-iwlwifi.h
index 6cb66a988271..223b8752f924 100644
--- a/drivers/net/wireless/iwlwifi/iwl-devtrace-iwlwifi.h
+++ b/drivers/net/wireless/iwlwifi/iwl-devtrace-iwlwifi.h
@@ -116,11 +116,11 @@ TRACE_EVENT(iwlwifi_dev_ucode_error,
 	TP_PROTO(const struct device *dev, u32 desc, u32 tsf_low,
 		 u32 data1, u32 data2, u32 line, u32 blink1,
 		 u32 blink2, u32 ilink1, u32 ilink2, u32 bcon_time,
-		 u32 gp1, u32 gp2, u32 gp3, u32 ucode_ver, u32 hw_ver,
+		 u32 gp1, u32 gp2, u32 gp3, u32 major, u32 minor, u32 hw_ver,
 		 u32 brd_ver),
 	TP_ARGS(dev, desc, tsf_low, data1, data2, line,
 		blink1, blink2, ilink1, ilink2, bcon_time, gp1, gp2,
-		gp3, ucode_ver, hw_ver, brd_ver),
+		gp3, major, minor, hw_ver, brd_ver),
 	TP_STRUCT__entry(
 		DEV_ENTRY
 		__field(u32, desc)
@@ -136,7 +136,8 @@ TRACE_EVENT(iwlwifi_dev_ucode_error,
 		__field(u32, gp1)
 		__field(u32, gp2)
 		__field(u32, gp3)
-		__field(u32, ucode_ver)
+		__field(u32, major)
+		__field(u32, minor)
 		__field(u32, hw_ver)
 		__field(u32, brd_ver)
 	),
@@ -155,21 +156,22 @@ TRACE_EVENT(iwlwifi_dev_ucode_error,
 		__entry->gp1 =3D gp1;
 		__entry->gp2 =3D gp2;
 		__entry->gp3 =3D gp3;
-		__entry->ucode_ver =3D ucode_ver;
+		__entry->major =3D major;
+		__entry->minor =3D minor;
 		__entry->hw_ver =3D hw_ver;
 		__entry->brd_ver =3D brd_ver;
 	),
 	TP_printk("[%s] #%02d %010u data 0x%08X 0x%08X line %u, "
 		  "blink 0x%05X 0x%05X ilink 0x%05X 0x%05X "
-		  "bcon_tm %010u gp 0x%08X 0x%08X 0x%08X uCode 0x%08X "
-		  "hw 0x%08X brd 0x%08X",
+		  "bcon_tm %010u gp 0x%08X 0x%08X 0x%08X major 0x%08X "
+		  "minor 0x%08X hw 0x%08X brd 0x%08X",
 		  __get_str(dev), __entry->desc, __entry->tsf_low,
 		  __entry->data1,
 		  __entry->data2, __entry->line, __entry->blink1,
 		  __entry->blink2, __entry->ilink1, __entry->ilink2,
 		  __entry->bcon_time, __entry->gp1, __entry->gp2,
-		  __entry->gp3, __entry->ucode_ver, __entry->hw_ver,
-		  __entry->brd_ver)
+		  __entry->gp3, __entry->major, __entry->minor,
+		  __entry->hw_ver, __entry->brd_ver)
 );
=20
 TRACE_EVENT(iwlwifi_dev_ucode_event,
--=20
2.1.4

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/lg1+9uPQq9RrnrzOTsT_xUc
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVK3W9AAoJEMDTa8Ir7ZwVtdgQAJITUEfs5CmgR2dIf5BwxDGn
OKOGaDpymtdRrO8qy0NeIyYUQHMPtbGYgs2pBx6kXSs0e9VzgIKaRdrrvznNCYV/
BjoQKS1rBtEK5P4rg4x3OF2cKY2rcStV6IU3k0R6QqxULDER3gWeEohpnLNlTkDu
sT2OIH3T1tN/f9J/2IdbqARUsNMPec5E1mGrLYANcdkf7K9hTarlhZTJFOmGYh+F
s97UHBysCUFI5bOIhPdY3pZQ9wt/wDtZyPZEhajaR+HqqB5hRErwLVImmlEoM6uj
7tk8mguHE5etyQKdFKNOcoL+hkik2ooNsh1wYK2r0AYqISaxRjZB/yzlB70ipL0T
ONrT2DpXPXkz6nZ02o89jZhUOFEfZxyQPLS0St+j31G3By5gZkCVBjnZtMcUt0f2
3l37gKhaax72Ke1GJPpMZbiywP9j5KTqRxXVRVgEb59k6KrWpUcy6m/kztqP8kk5
zo6JnLomYspmnbaDhegwFDnLKbK0b8HyS2ABy1tSLfcNSUeWerwbnIw6L5jguC0o
B2Lc2SdQt5Pz21SREDEbzX8SLYO7P05qENwYa+FR49GOavyWDhLXDYDfGy0ycxN6
A+Isbg3dPldl5RSesfnTdMDMD39r4rKU3yANGypkHO96VKYhdixH4bXVkljgaZ2K
6RWVQSk4AzYhL0NFlYDi
=c3pl
-----END PGP SIGNATURE-----

--Sig_/lg1+9uPQq9RrnrzOTsT_xUc--
