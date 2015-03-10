From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH net-next] fib_trie: call fib_table_flush_external under
 RTNL
Date: Tue, 10 Mar 2015 13:38:03 -0700
Message-ID: <54FF562B.2060701@redhat.com>
References: <20150310183555.GB1743@kria> <1426017834-24209-1-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfeldma@gmail.com
To: Sabrina Dubroca <sd@queasysnail.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42265 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751368AbbCJUiJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 16:38:09 -0400
In-Reply-To: <1426017834-24209-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/10/2015 01:03 PM, Sabrina Dubroca wrote:
> Move rtnl_lock() before the call to fib4_rules_exit so that
> fib_table_flush_external is called under RTNL.
>
> Fixes: 104616e74e0b ("switchdev: don't support custom ip rules, for now")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> ---
>   net/ipv4/fib_frontend.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> index e067770235bf..ed94bc80eb78 100644
> --- a/net/ipv4/fib_frontend.c
> +++ b/net/ipv4/fib_frontend.c
> @@ -1126,11 +1126,12 @@ static void ip_fib_net_exit(struct net *net)
>   {
>   	unsigned int i;
>   
> +	rtnl_lock();
> +
>   #ifdef CONFIG_IP_MULTIPLE_TABLES
>   	fib4_rules_exit(net);
>   #endif
>   
> -	rtnl_lock();
>   	for (i = 0; i < FIB_TABLE_HASHSZ; i++) {
>   		struct hlist_head *head = &net->ipv4.fib_table_hash[i];
>   		struct hlist_node *tmp;

Acked-by: Alexander Duyck <alexander.h.duyck@redhat.com>
