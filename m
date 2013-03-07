From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix: sparse warning in inet_csk_prepare_forced_close
Date: Thu, 07 Mar 2013 16:31:54 -0500 (EST)
Message-ID: <20130307.163154.1852978287105127033.davem@davemloft.net>
References: <1362659673-28895-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46417 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759805Ab3CGVbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 16:31:55 -0500
In-Reply-To: <1362659673-28895-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Thu,  7 Mar 2013 13:34:33 +0100

> In e337e24d66 (inet: Fix kmemleak in tcp_v4/6_syn_recv_sock and
> dccp_v4/6_request_recv_sock) I introduced the function
> inet_csk_prepare_forced_close, which does a call to bh_unlock_sock().
> This produces a sparse-warning.
> 
> This patch adds the missing __releases.
> 
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> ---
>  net/ipv4/inet_connection_sock.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
> index 7d1874b..804c98f 100644
> --- a/net/ipv4/inet_connection_sock.c
> +++ b/net/ipv4/inet_connection_sock.c
> @@ -735,6 +735,7 @@ EXPORT_SYMBOL(inet_csk_destroy_sock);
>   * tcp/dccp_create_openreq_child().
>   */
>  void inet_csk_prepare_forced_close(struct sock *sk)
> +__releases(&sk->sk_lock.slock)

This should be indented by one TAB, I fixed this while applying your
patch, thanks.
