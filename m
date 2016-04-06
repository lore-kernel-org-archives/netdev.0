From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 1/2] sctp: compress bit-wide flags to a bitfield on
 sctp_sock
Date: Wed, 06 Apr 2016 12:53:24 -0700
Message-ID: <1459972404.6715.65.camel@perches.com>
References: <cover.1459952558.git.marcelo.leitner@gmail.com>
	 <69a5ce012d9978ce73aade0004c5937964c54d61.1459952558.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0068.hostedemail.com ([216.40.44.68]:47800 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752333AbcDFTx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 15:53:28 -0400
In-Reply-To: <69a5ce012d9978ce73aade0004c5937964c54d61.1459952558.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-04-06 at 14:53 -0300, Marcelo Ricardo Leitner wrote:
> It wastes space and gets worse as we add new flags, so convert bit-wi=
de
> flags to a bitfield.
>=20
> Currently it already saves 4 bytes in sctp_sock, which are left as ho=
les
> in it for now. The whole struct needs packing, which should be done i=
n
> another patch.
>=20
> Note that do_auto_asconf cannot be merged, as explained in the commen=
t
> before it.
>=20
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> ---
[]
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
[]
> @@ -210,14 +210,14 @@ struct sctp_sock {
> =A0	int user_frag;
> =A0
> =A0	__u32 autoclose;
> -	__u8 nodelay;
> -	__u8 disable_fragments;
> -	__u8 v4mapped;
> -	__u8 frag_interleave;
> =A0	__u32 adaptation_ind;
> =A0	__u32 pd_point;
> -	__u8 recvrcvinfo;
> -	__u8 recvnxtinfo;
> +	__u16	nodelay:1,
> +		disable_fragments:1,
> +		v4mapped:1,
> +		frag_interleave:1,
> +		recvrcvinfo:1,
> +		recvnxtinfo:1;

Might as well make this __u32 as the next field would be
aligned on an atomic_t

It might be better if these fields didn't use the __ prefix.
