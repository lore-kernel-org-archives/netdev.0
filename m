From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH net-next v8 2/3] Add a eBPF helper function to retrieve
 socket uid
Date: Fri, 21 Apr 2017 00:39:05 +0200
Message-ID: <3a912a7f-1894-e887-a44a-7c5a9b65c8d2@digikod.net>
References: <1490228856-4546-1-git-send-email-chenbofeng.kernel@gmail.com>
 <1490228856-4546-3-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="mSaICtCHLJDdAMV7o6DJWQq4AWcDJljms"
Cc: Lorenzo Colitti <lorenzo-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Chenbo Feng <fengc-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Chenbo Feng <chenbofeng.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1490228856-4546-3-git-send-email-chenbofeng.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--mSaICtCHLJDdAMV7o6DJWQq4AWcDJljms
Content-Type: multipart/mixed; boundary="Cij4fKCRtDWeBq8AdFQ7RenJ4TI4Jh9N3";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
To: Chenbo Feng <chenbofeng.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>,
 Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Cc: Lorenzo Colitti <lorenzo-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
 Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Chenbo Feng <fengc-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
 Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Message-ID: <3a912a7f-1894-e887-a44a-7c5a9b65c8d2-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH net-next v8 2/3] Add a eBPF helper function to retrieve
 socket uid
References: <1490228856-4546-1-git-send-email-chenbofeng.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
 <1490228856-4546-3-git-send-email-chenbofeng.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
In-Reply-To: <1490228856-4546-3-git-send-email-chenbofeng.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

--Cij4fKCRtDWeBq8AdFQ7RenJ4TI4Jh9N3
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: quoted-printable


On 23/03/2017 01:27, Chenbo Feng wrote:
> From: Chenbo Feng <fengc-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>=20
> Returns the owner uid of the socket inside a sk_buff. This is useful to=

> perform per-UID accounting of network traffic or per-UID packet
> filtering. The socket need to be a fullsock otherwise overflowuid is
> returned.
>=20
> Signed-off-by: Chenbo Feng <fengc-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> ---
>  include/uapi/linux/bpf.h       |  9 ++++++++-
>  net/core/filter.c              | 22 ++++++++++++++++++++++
>  tools/include/uapi/linux/bpf.h |  3 ++-
>  3 files changed, 32 insertions(+), 2 deletions(-)
>=20
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index dc81a9f..ff42111 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -462,6 +462,12 @@ union bpf_attr {
>   *     @skb: pointer to skb
>   *     Return: 8 Bytes non-decreasing number on success or 0 if the so=
cket
>   *     field is missing inside sk_buff
> + *
> + * u32 bpf_get_socket_uid(skb)
> + *     Get the owner uid of the socket stored inside sk_buff.
> + *     @skb: pointer to skb
> + *     Return: uid of the socket owner on success or 0 if the socket p=
ointer
> + *     inside sk_buff is NULL

What about UID 0? Why not returning -1 on error?

>   */
>  #define __BPF_FUNC_MAPPER(FN)		\
>  	FN(unspec),			\
> @@ -510,7 +516,8 @@ union bpf_attr {
>  	FN(skb_change_head),		\
>  	FN(xdp_adjust_head),		\
>  	FN(probe_read_str),		\
> -	FN(get_socket_cookie),
> +	FN(get_socket_cookie),		\
> +	FN(get_socket_uid),
> =20
>  /* integer value in 'imm' field of BPF_CALL instruction selects which =
helper
>   * function eBPF program intends to call
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 5b65ae3..93cc4af 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -2612,6 +2612,24 @@ static const struct bpf_func_proto bpf_get_socke=
t_cookie_proto =3D {
>  	.arg1_type      =3D ARG_PTR_TO_CTX,
>  };
> =20
> +BPF_CALL_1(bpf_get_socket_uid, struct sk_buff *, skb)
> +{
> +	struct sock *sk =3D sk_to_full_sk(skb->sk);
> +	kuid_t kuid;
> +
> +	if (!sk || !sk_fullsock(sk))
> +		return overflowuid;
> +	kuid =3D sock_net_uid(sock_net(sk), sk);
> +	return from_kuid_munged(sock_net(sk)->user_ns, kuid);
> +}
> +
> +static const struct bpf_func_proto bpf_get_socket_uid_proto =3D {
> +	.func           =3D bpf_get_socket_uid,
> +	.gpl_only       =3D false,
> +	.ret_type       =3D RET_INTEGER,
> +	.arg1_type      =3D ARG_PTR_TO_CTX,
> +};
> +
>  static const struct bpf_func_proto *
>  bpf_base_func_proto(enum bpf_func_id func_id)
>  {
> @@ -2648,6 +2666,8 @@ sk_filter_func_proto(enum bpf_func_id func_id)
>  		return &bpf_skb_load_bytes_proto;
>  	case BPF_FUNC_get_socket_cookie:
>  		return &bpf_get_socket_cookie_proto;
> +	case BPF_FUNC_get_socket_uid:
> +		return &bpf_get_socket_uid_proto;
>  	default:
>  		return bpf_base_func_proto(func_id);
>  	}
> @@ -2709,6 +2729,8 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
>  		return &bpf_skb_under_cgroup_proto;
>  	case BPF_FUNC_get_socket_cookie:
>  		return &bpf_get_socket_cookie_proto;
> +	case BPF_FUNC_get_socket_uid:
> +		return &bpf_get_socket_uid_proto;
>  	default:
>  		return bpf_base_func_proto(func_id);
>  	}
> diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/=
bpf.h
> index a94bdd3..4a2d56d 100644
> --- a/tools/include/uapi/linux/bpf.h
> +++ b/tools/include/uapi/linux/bpf.h
> @@ -504,7 +504,8 @@ union bpf_attr {
>  	FN(skb_change_head),		\
>  	FN(xdp_adjust_head),		\
>  	FN(probe_read_str),		\
> -	FN(get_socket_cookie),
> +	FN(get_socket_cookie),		\
> +	FN(get_socket_uid),
> =20
>  /* integer value in 'imm' field of BPF_CALL instruction selects which =
helper
>   * function eBPF program intends to call
>=20


--Cij4fKCRtDWeBq8AdFQ7RenJ4TI4Jh9N3--

--mSaICtCHLJDdAMV7o6DJWQq4AWcDJljms
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAlj5OIkACgkQIt7+33O9
apXYoAgAkuUaG84OhlaJu5rCx8J8+9qb4Pbkct0IV6tQc7iL4SZX4eVVW4zXFC5P
PqplbYCeaJHM4sPM3nyRWg7ySgT4ifaYg/j3+l1peBz2kWJ1a1FaYRl6LdWmxcQi
mBfksLVzxBesrMVPqVLuSrO/RbWayGqsSDiNGivjpzXS9WP835nSMKgdGiQCcpCD
kqSxYPerOFjA4qXfZWwPKqN3Ezt326WukIYWVpNEpKRKJhOTC2BYPwk66A3OkcPd
8tSIm4L8KQeYn01n/3fYoH/9jzjAgtLSp+v1oNRUgxtqjFriA0RT6VztN/SGEYBS
nZQBALtP7tga9+CI4ZDSbt6mx6yKmg==
=ABYo
-----END PGP SIGNATURE-----

--mSaICtCHLJDdAMV7o6DJWQq4AWcDJljms--
