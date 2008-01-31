From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 6/6] [TCP]: Reorganize struct tcp_sock to save 16 bytes
 on 64-bit arch
Date: Thu, 31 Jan 2008 20:57:53 +0100
Message-ID: <47A22841.6090508@cosmosbay.com>
References: y <1201804304-28777-1-git-send-email-acme@redhat.com> <1201804304-28777-2-git-send-email-acme@redhat.com> <1201804304-28777-3-git-send-email-acme@redhat.com> <1201804304-28777-4-git-send-email-acme@redhat.com> <1201804304-28777-5-git-send-email-acme@redhat.com> <1201804304-28777-6-git-send-email-acme@redhat.com> <1201804304-28777-7-git-send-email-acme@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	dccp@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604003av.neufgp.fr ([84.96.92.124]:59977
	"EHLO neuf-infra-smtp-out-sp604003av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754674AbYAaT6R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 14:58:17 -0500
In-Reply-To: <1201804304-28777-7-git-send-email-acme@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnaldo Carvalho de Melo a =E9crit :
> /home/acme/git/net-2.6/net/ipv6/tcp_ipv6.c:
>   struct tcp_sock  |  -16
>   struct tcp6_sock |  -16
>  2 structs changed
>=20
> Now it is at:
>=20
> /* size: 1552, cachelines: 25 */
> /* paddings: 2, sum paddings: 8 */
> /* last cacheline: 16 bytes */
>=20
> As soon as we stop using skb_queue_list we'll get it down to 24 cache=
lines.
>=20
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
> ---
>  include/linux/tcp.h |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
>=20
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index 08027f1..f48644d 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -304,7 +304,6 @@ struct tcp_sock {
>  	u32	rtt_seq;	/* sequence number to update rttvar	*/
> =20
>  	u32	packets_out;	/* Packets which are "in flight"	*/
> -	u32	retrans_out;	/* Retransmitted packets out		*/
>  /*
>   *      Options received (usually on last packet, some only on SYN p=
ackets).
>   */
> @@ -332,6 +331,8 @@ struct tcp_sock {
> =20
>  	struct tcp_sack_block recv_sack_cache[4];
> =20
> +	u32	retrans_out;	/* Retransmitted packets out		*/
> +

Hum... retrans_out should sit close to packets_out (or lost_out/sacked_=
out=20
???), please.

'struct tcp_sock' is very large on 64 bits, so I would prefer to make s=
ure=20
most paths dont need to touch all 24 cache lines (or 25 cache lines).

