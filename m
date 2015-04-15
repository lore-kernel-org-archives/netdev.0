From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the ftrace tree with the net-next
 tree
Date: Wed, 15 Apr 2015 11:23:23 +1000
Message-ID: <20150415112323.057080ad@canb.auug.org.au>
References: <20150413175224.73a9baff@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/G+ffXACnC8+UO.V8LlX6zZZ"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>
To: Steven Rostedt <rostedt@goodmis.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150413175224.73a9baff@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/G+ffXACnC8+UO.V8LlX6zZZ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

On Mon, 13 Apr 2015 17:52:24 +1000 Stephen Rothwell <sfr@canb.auug.org.au> =
wrote:
>
> Today's linux-next merge of the ftrace tree got a conflict in
> drivers/net/wireless/iwlwifi/iwl-devtrace.h between commit 7e1223b50089
> ("iwlwifi: mvm: new Alive / error table API") from the net-next tree
> and commit c5ef935d01a2 ("iwlwifi: Move each system tracepoints to
> their own header") from the ftrace tree.
>=20
> I fixed it up (see patch below, since this code was moved to a new file)
> and can carry the fix as necessary (no action is required).
>=20
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Mon, 13 Apr 2015 17:21:30 +1000
> Subject: [PATCH] iwlwifi: mvm: fix up for tracing split
>=20
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>  drivers/net/wireless/iwlwifi/iwl-devtrace-iwlwifi.h | 18 ++++++++++-----=
---
>  1 file changed, 10 insertions(+), 8 deletions(-)
>=20
> diff --git a/drivers/net/wireless/iwlwifi/iwl-devtrace-iwlwifi.h b/driver=
s/net/wireless/iwlwifi/iwl-devtrace-iwlwifi.h
> index 6cb66a988271..223b8752f924 100644
> --- a/drivers/net/wireless/iwlwifi/iwl-devtrace-iwlwifi.h
> +++ b/drivers/net/wireless/iwlwifi/iwl-devtrace-iwlwifi.h
> @@ -116,11 +116,11 @@ TRACE_EVENT(iwlwifi_dev_ucode_error,
>  	TP_PROTO(const struct device *dev, u32 desc, u32 tsf_low,
>  		 u32 data1, u32 data2, u32 line, u32 blink1,
>  		 u32 blink2, u32 ilink1, u32 ilink2, u32 bcon_time,
> -		 u32 gp1, u32 gp2, u32 gp3, u32 ucode_ver, u32 hw_ver,
> +		 u32 gp1, u32 gp2, u32 gp3, u32 major, u32 minor, u32 hw_ver,
>  		 u32 brd_ver),
>  	TP_ARGS(dev, desc, tsf_low, data1, data2, line,
>  		blink1, blink2, ilink1, ilink2, bcon_time, gp1, gp2,
> -		gp3, ucode_ver, hw_ver, brd_ver),
> +		gp3, major, minor, hw_ver, brd_ver),
>  	TP_STRUCT__entry(
>  		DEV_ENTRY
>  		__field(u32, desc)
> @@ -136,7 +136,8 @@ TRACE_EVENT(iwlwifi_dev_ucode_error,
>  		__field(u32, gp1)
>  		__field(u32, gp2)
>  		__field(u32, gp3)
> -		__field(u32, ucode_ver)
> +		__field(u32, major)
> +		__field(u32, minor)
>  		__field(u32, hw_ver)
>  		__field(u32, brd_ver)
>  	),
> @@ -155,21 +156,22 @@ TRACE_EVENT(iwlwifi_dev_ucode_error,
>  		__entry->gp1 =3D gp1;
>  		__entry->gp2 =3D gp2;
>  		__entry->gp3 =3D gp3;
> -		__entry->ucode_ver =3D ucode_ver;
> +		__entry->major =3D major;
> +		__entry->minor =3D minor;
>  		__entry->hw_ver =3D hw_ver;
>  		__entry->brd_ver =3D brd_ver;
>  	),
>  	TP_printk("[%s] #%02d %010u data 0x%08X 0x%08X line %u, "
>  		  "blink 0x%05X 0x%05X ilink 0x%05X 0x%05X "
> -		  "bcon_tm %010u gp 0x%08X 0x%08X 0x%08X uCode 0x%08X "
> -		  "hw 0x%08X brd 0x%08X",
> +		  "bcon_tm %010u gp 0x%08X 0x%08X 0x%08X major 0x%08X "
> +		  "minor 0x%08X hw 0x%08X brd 0x%08X",
>  		  __get_str(dev), __entry->desc, __entry->tsf_low,
>  		  __entry->data1,
>  		  __entry->data2, __entry->line, __entry->blink1,
>  		  __entry->blink2, __entry->ilink1, __entry->ilink2,
>  		  __entry->bcon_time, __entry->gp1, __entry->gp2,
> -		  __entry->gp3, __entry->ucode_ver, __entry->hw_ver,
> -		  __entry->brd_ver)
> +		  __entry->gp3, __entry->major, __entry->minor,
> +		  __entry->hw_ver, __entry->brd_ver)
>  );
> =20
>  TRACE_EVENT(iwlwifi_dev_ucode_event,

This patch is now needed when the net-next tree is merged with Linus'
tree ...

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/G+ffXACnC8+UO.V8LlX6zZZ
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVLb2PAAoJEMDTa8Ir7ZwVNlYP/iTHvWuPhsbLUC8GWd+goynV
+yD9oeHXFpFRXgoraYlfD9Z1Niqy1CKEQG1cXyNKueE+Nyr8qiKPewPmjDLA1tTr
WsHl++td8f9l+W5ypXpfnHIyK/x/vGjQ6mQdmTtB4yyrwn1uUZ7s/KQ7ntcA1Y6E
Jq8gLHs54iPTTAwniO6ikCeJzTnjTqosbRRogxoGWrrtsL/90/ngqcAVmGEKTSKQ
1/wv/Nr1fToYzZUfs4BBTWoGr4yY+bbZ99i34dF+W3TLTZEAPsXaTY2ExMq/jncO
Z82eaz0kzwnsaEP7WBQR7cVkm5YxM7GcFXWhT4aoTR1o8LOl21H1qgO4q/MzXQHY
eH7gu2Qy1J4Cy8V5yOD/cxAwBT6k9mUKok9jHbm38biYPfyG98aY8M0DiTILeecp
lp9Jc76ZGB9HnFJ11CvpoPNvYYW9otsCxAAR7g47TnVUyW4s2wMpCrfE6eQjt/KU
ir+fmiNJq3G27lFb6KW9RZcYUqLMwJ2G91FQvF+rQGjZnf5H6B7/6yMpcCwPltcL
IcKw0TBBntcGyEmJO8LxniT2X/+AgJndIU+F3OPi/WdGT/0KYHDPv2i6Z+1e+qnz
p984NgUpTcP1i2gKci6gN8qerv84PhvqOuMhgy/MKSil3TdaLlaAlt35ooTlJEtN
bHPNvmW7/ZI1Y6kD7As6
=muIN
-----END PGP SIGNATURE-----

--Sig_/G+ffXACnC8+UO.V8LlX6zZZ--
