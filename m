From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: Re: [PATCH net] net: sctp: fix ASCONF to allow non SCTP_ADDR_SRC addresses in ipv6
Date: Tue, 22 Oct 2013 21:33:15 +0200
Message-ID: <EA0201FF-EB0D-4421-B990-DB569EB7DCA1@sfc.wide.ad.jp>
References: <1382459696-1732-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:44523 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754046Ab3JVTjQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 15:39:16 -0400
In-Reply-To: <1382459696-1732-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Oct 22, 2013, at 6:34 PM, Daniel Borkmann wrote:

> Commit 8a07eb0a50 ("sctp: Add ASCONF operation on the single-homed host")
> implemented possible use of IPv4 addresses with non SCTP_ADDR_SRC state
> as source address when sending ASCONF (ADD) packets, but IPv6 part for
> that was not implemented in 8a07eb0a50. Therefore, as this is not restricted
> to IPv4-only, fix this up to allow the same for IPv6 addresses in SCTP.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Michio Honda <micchie@sfc.wide.ad.jp>
> ---
> net/sctp/ipv6.c | 4 +++-
> 1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
> index e7b2d4f..96a5591 100644
> --- a/net/sctp/ipv6.c
> +++ b/net/sctp/ipv6.c
> @@ -279,7 +279,9 @@ static void sctp_v6_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
> 		sctp_v6_to_addr(&dst_saddr, &fl6->saddr, htons(bp->port));
> 		rcu_read_lock();
> 		list_for_each_entry_rcu(laddr, &bp->address_list, list) {
> -			if (!laddr->valid || (laddr->state != SCTP_ADDR_SRC))
> +			if (!laddr->valid || laddr->state == SCTP_ADDR_DEL ||
> +			    (laddr->state != SCTP_ADDR_SRC &&
> +			     !asoc->src_out_of_asoc_ok))
> 				continue;
> 
> 			/* Do not compare against v4 addrs */
> -- 
> 1.8.3.1
Acked-by: Michio Honda <micchie@sfc.wide.ad.jp>
