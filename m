From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net] net: sctp: fix ASCONF to allow non SCTP_ADDR_SRC
 addresses in ipv6
Date: Wed, 23 Oct 2013 04:54:22 -0400
Message-ID: <CAGCdqXHLFiGwxATpoYfCDEGJLQH2Rej4xqeyqsndwb2B1tBjCg@mail.gmail.com>
References: <1382459696-1732-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	Michio Honda <micchie@sfc.wide.ad.jp>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:45353 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751052Ab3JWIyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 04:54:23 -0400
In-Reply-To: <1382459696-1732-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 22, 2013 at 12:34 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
>
> Commit 8a07eb0a50 ("sctp: Add ASCONF operation on the single-homed host")
> implemented possible use of IPv4 addresses with non SCTP_ADDR_SRC state
> as source address when sending ASCONF (ADD) packets, but IPv6 part for
> that was not implemented in 8a07eb0a50. Therefore, as this is not restricted
> to IPv4-only, fix this up to allow the same for IPv6 addresses in SCTP.
>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Michio Honda <micchie@sfc.wide.ad.jp>

[stupid gmail]

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

> ---
>  net/sctp/ipv6.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
> index e7b2d4f..96a5591 100644
> --- a/net/sctp/ipv6.c
> +++ b/net/sctp/ipv6.c
> @@ -279,7 +279,9 @@ static void sctp_v6_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
>                 sctp_v6_to_addr(&dst_saddr, &fl6->saddr, htons(bp->port));
>                 rcu_read_lock();
>                 list_for_each_entry_rcu(laddr, &bp->address_list, list) {
> -                       if (!laddr->valid || (laddr->state != SCTP_ADDR_SRC))
> +                       if (!laddr->valid || laddr->state == SCTP_ADDR_DEL ||
> +                           (laddr->state != SCTP_ADDR_SRC &&
> +                            !asoc->src_out_of_asoc_ok))
>                                 continue;
>
>                         /* Do not compare against v4 addrs */
> --
> 1.8.3.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
