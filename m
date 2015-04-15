From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [GIT] Networking
Date: Wed, 15 Apr 2015 14:34:26 +1000
Message-ID: <20150415143426.77bcb8e0@canb.auug.org.au>
References: <20150415.001650.965895634678897926.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/L/Wmml3U2HCm_uUawcBIMNU"; protocol="application/pgp-signature"
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:35694 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751301AbbDOEee (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2015 00:34:34 -0400
In-Reply-To: <20150415.001650.965895634678897926.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/L/Wmml3U2HCm_uUawcBIMNU
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Wed, 15 Apr 2015 00:16:50 -0400 (EDT) David Miller <davem@davemloft.net>=
 wrote:
>
> The first has to do with Stephen Rothwells movement of trace entries
> into individual files while meanwhile the wireless folks were adding
> new ones or changing the signature of existing ones.

Umm, it wasn't me moving stuff, I just coped :-)

> For net/mac80211/trace.h, keep the hunk that adds the
> drv_wake_tx_queue trace event.  Then remove the hunk from "#ifdef
> CONFIG_MAC80211_MESSAGE_TRACING" until the "#endif" closing that
> ifdef.
>=20
> For drivers/net/wireless/iwlwifi/iwl-devtrace.h, take the trace entry
> definition for iwlwifi_dev_ucode_error from my tree and use it to replace
> what is in drivers/net/wireless/iwlwifi/iwl-devtrace-iwlwifi.h   Then
> remove everything else in the conflict section of iwl-devtrace.h

or for drivers/net/wireless/iwlwifi/iwl-devtrace-iwlwifi.h, apply this:

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

> The second set of conflicts have to do with BPF stuff.
>=20
> 	samples/bpf/Makefile - Trivial, overlapping additions.
> 	include/uapi/linux/bpf.h - Likewise.
>=20
> In kernel/events/core.c you'll have to change "prog->aux->prog_type"
> into "prog->type".

i.e. apply this:

diff --git a/kernel/events/core.c b/kernel/events/core.c
index 06917d537302..81aa3a4ece9f 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -6729,7 +6729,7 @@ static int perf_event_set_bpf_prog(struct perf_event =
*event, u32 prog_fd)
 	if (IS_ERR(prog))
 		return PTR_ERR(prog);
=20
-	if (prog->aux->prog_type !=3D BPF_PROG_TYPE_KPROBE) {
+	if (prog->type !=3D BPF_PROG_TYPE_KPROBE) {
 		/* valid fd, but invalid bpf program type */
 		bpf_prog_put(prog);
 		return -EINVAL;

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/L/Wmml3U2HCm_uUawcBIMNU
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVLepXAAoJEMDTa8Ir7ZwVH7sP/ixbIR4QihtkRypM46Fl2sp0
R5eLUaif6K6Drxhb0Fk7DnWraqSkdjYxK2bnHP/tih08zfPrHAizQsiFIMSejI5m
gINsJfosfS22hxdTt5WUVuWRRrdcrpCR6dzK/jSM7PT494hHCS1VwDu2YaI/Wyx8
N5hymXGjK/hUFQB8W3n3NhweCfr5RP5pGviuz8XYkzL3S83H30q7qSUU3dadM8lN
BDtUTekUz0YNO0zjSDBi36jpt8w2DHT0gVDCNRKRVWH59cWUE6BBqZYyz2ZrbS9j
zo79OoShDLxUxg9Kp7kHv8J2g3Y62XUZImG7GqYUF1q1nT014+biyzYBHhV26fjw
m/ZQAztSx/QbH4CmobMIquZWjhviK8lGpDM5uBRGks7YUIsM2jUlWJbo5+Nz9N8B
2Z6bUNpC2XNoJiJWGBKyyBFlV3Gq3uS0e0CTzICq9zENnqbflCMdvl0RnYtGadzC
8/DOUIm24f88q8UI3w6NYaEZo98OVfQnRmHkZApFlhfvchctLHZomley6YQunltQ
1iGD+lR8C6Vrvibd+FMpzrToKj3UGK15reQ5ZiN7kDewaZUIb+xU99A70WF+SR9a
WROoYcdy8eLAXtP9NEms1/tLQGiflIthMXqqlLSelHB/O52oCu6FtvXt/OoPWymW
KhAZPPEXDuVNUKhzsrbq
=BXXr
-----END PGP SIGNATURE-----

--Sig_/L/Wmml3U2HCm_uUawcBIMNU--
