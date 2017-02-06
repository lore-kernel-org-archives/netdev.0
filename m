From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH net-next v1 4/7] tools: Sync
 {,tools/}include/uapi/linux/bpf.h
Date: Mon, 6 Feb 2017 20:51:38 +0100
Message-ID: <7e1ff309-959f-445f-ba64-1f67bad9b81b@digikod.net>
References: <20170205231428.23846-1-mic@digikod.net>
 <20170205231428.23846-4-mic@digikod.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="HHPjGPB2V23AveXGr3tWu20exoKgddSBd"
Cc: netdev@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170205231428.23846-4-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--HHPjGPB2V23AveXGr3tWu20exoKgddSBd
Content-Type: multipart/mixed; boundary="viUtu4JtBahXhdmvM6DVwfVjA5kaN1JUS";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
 Arnaldo Carvalho de Melo <acme@redhat.com>,
 Daniel Borkmann <daniel@iogearbox.net>,
 "David S . Miller" <davem@davemloft.net>
Message-ID: <7e1ff309-959f-445f-ba64-1f67bad9b81b@digikod.net>
Subject: Re: [PATCH net-next v1 4/7] tools: Sync
 {,tools/}include/uapi/linux/bpf.h
References: <20170205231428.23846-1-mic@digikod.net>
 <20170205231428.23846-4-mic@digikod.net>
In-Reply-To: <20170205231428.23846-4-mic@digikod.net>

--viUtu4JtBahXhdmvM6DVwfVjA5kaN1JUS
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

This patch only make sense in net-next, however.

On 06/02/2017 00:14, Micka=C3=ABl Sala=C3=BCn wrote:
> The tools version of this header is out of date; update it to the lates=
t
> version from kernel header.
>=20
> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
> Cc: Alexei Starovoitov <ast@fb.com>
> Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: David S. Miller <davem@davemloft.net>
> ---
>  tools/include/uapi/linux/bpf.h | 23 ++++++++++++++++++++++-
>  1 file changed, 22 insertions(+), 1 deletion(-)
>=20
> diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/=
bpf.h
> index 0eb0e87dbe9f..e07fd5a324e6 100644
> --- a/tools/include/uapi/linux/bpf.h
> +++ b/tools/include/uapi/linux/bpf.h
> @@ -63,6 +63,12 @@ struct bpf_insn {
>  	__s32	imm;		/* signed immediate constant */
>  };
> =20
> +/* Key of an a BPF_MAP_TYPE_LPM_TRIE entry */
> +struct bpf_lpm_trie_key {
> +	__u32	prefixlen;	/* up to 32 for AF_INET, 128 for AF_INET6 */
> +	__u8	data[0];	/* Arbitrary size */
> +};
> +
>  /* BPF syscall commands, see bpf(2) man-page for details. */
>  enum bpf_cmd {
>  	BPF_MAP_CREATE,
> @@ -89,6 +95,7 @@ enum bpf_map_type {
>  	BPF_MAP_TYPE_CGROUP_ARRAY,
>  	BPF_MAP_TYPE_LRU_HASH,
>  	BPF_MAP_TYPE_LRU_PERCPU_HASH,
> +	BPF_MAP_TYPE_LPM_TRIE,
>  };
> =20
>  enum bpf_prog_type {
> @@ -430,6 +437,18 @@ union bpf_attr {
>   *     @xdp_md: pointer to xdp_md
>   *     @delta: An positive/negative integer to be added to xdp_md.data=

>   *     Return: 0 on success or negative on error
> + *
> + * int bpf_probe_read_str(void *dst, int size, const void *unsafe_ptr)=

> + *     Copy a NUL terminated string from unsafe address. In case the s=
tring
> + *     length is smaller than size, the target is not padded with furt=
her NUL
> + *     bytes. In case the string length is larger than size, just coun=
t-1
> + *     bytes are copied and the last byte is set to NUL.
> + *     @dst: destination address
> + *     @size: maximum number of bytes to copy, including the trailing =
NUL
> + *     @unsafe_ptr: unsafe address
> + *     Return:
> + *       > 0 length of the string including the trailing NUL on succes=
s
> + *       < 0 error
>   */
>  #define __BPF_FUNC_MAPPER(FN)		\
>  	FN(unspec),			\
> @@ -476,7 +495,8 @@ union bpf_attr {
>  	FN(set_hash_invalid),		\
>  	FN(get_numa_node_id),		\
>  	FN(skb_change_head),		\
> -	FN(xdp_adjust_head),
> +	FN(xdp_adjust_head),		\
> +	FN(probe_read_str),
> =20
>  /* integer value in 'imm' field of BPF_CALL instruction selects which =
helper
>   * function eBPF program intends to call
> @@ -502,6 +522,7 @@ enum bpf_func_id {
>  /* BPF_FUNC_l4_csum_replace flags. */
>  #define BPF_F_PSEUDO_HDR		(1ULL << 4)
>  #define BPF_F_MARK_MANGLED_0		(1ULL << 5)
> +#define BPF_F_MARK_ENFORCE		(1ULL << 6)
> =20
>  /* BPF_FUNC_clone_redirect and BPF_FUNC_redirect flags. */
>  #define BPF_F_INGRESS			(1ULL << 0)
>=20


--viUtu4JtBahXhdmvM6DVwfVjA5kaN1JUS--

--HHPjGPB2V23AveXGr3tWu20exoKgddSBd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAliY08oACgkQIt7+33O9
apUMoAf+LyrbuArtQLmeJZ+RSdT3zEBzHZNtxZTTTcLOhC1kfz52aucZ/LsJrqRV
n07ZzgIwqiF1Y+kT6GTiCIqYTh844X0MJcbk3uDiVM1ZLK6lPVHhZubpRHv0w6Vu
n8moOPFFTgpEVBRt9JcKt7tBcIAF/mhW4AToU+XgObrDa4rv8dFVtNT7aUwYaAoN
7qUl/PbqG25DP8+ERM17WLMQDdy5/7s6o+L7tv8ryKuqSUUA/chdOn33q5W0onSk
cwg3pOT5kdnMfdC49ySw9OfNUu86p+6nMuQwNeqZu5vGjaqPy1cxz531HmvLEnkb
4qlEvLEw7xEGZF3vOOFUPokv5qaQ2w==
=B6xI
-----END PGP SIGNATURE-----

--HHPjGPB2V23AveXGr3tWu20exoKgddSBd--
