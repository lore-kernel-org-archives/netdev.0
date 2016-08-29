From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH v2 nf] netfilter: log: Check param to avoid overflow in nf_log_set
Date: Mon, 29 Aug 2016 18:30:09 +0800
Message-ID: <CA+6hz4oXVqwcaCH6aKVw-fq2JfmNCLAz-2WragGhdS5QvC_Sxg@mail.gmail.com>
References: <1472466328-5595-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        "David S. Miller" <davem@davemloft.net>,
        Netfilter Developer Mailing List
        <netfilter-devel@vger.kernel.org>, coreteam@netfilter.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Gao Feng <fgao@ikuai8.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f193.google.com ([209.85.217.193]:34592 "EHLO
        mail-ua0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750828AbcH2Kox (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 06:44:53 -0400
In-Reply-To: <1472466328-5595-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 29, 2016 at 6:25 PM,  <fgao@ikuai8.com> wrote:
> From: Gao Feng <fgao@ikuai8.com>
>
> The nf_log_set is an interface function, so it should do the strict sanity
> check of parameters. Convert the return value of nf_log_set as int instead
> of void. When the pf is invalid, return -EOPNOTSUPP.
>
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---
>  v2: Use ARRAY_SIZE(net->nf.nf_loggers) instead of NFPROTO_NUMPROTO;
>      Return error code -EOPNOTSUPP when pf is invalid;
>  v1: Initial patch
>
>  include/net/netfilter/nf_log.h       | 2 +-
>  net/bridge/netfilter/nf_log_bridge.c | 3 +--
>  net/ipv4/netfilter/nf_log_arp.c      | 3 +--
>  net/ipv4/netfilter/nf_log_ipv4.c     | 3 +--
>  net/ipv6/netfilter/nf_log_ipv6.c     | 3 +--
>  net/netfilter/nf_log.c               | 8 +++++---
>  6 files changed, 10 insertions(+), 12 deletions(-)
>
> diff --git a/include/net/netfilter/nf_log.h b/include/net/netfilter/nf_log.h
> index 83d855b..f4eebd0 100644
> --- a/include/net/netfilter/nf_log.h
> +++ b/include/net/netfilter/nf_log.h
> @@ -60,7 +60,7 @@ struct nf_logger {
>  int nf_log_register(u_int8_t pf, struct nf_logger *logger);
>  void nf_log_unregister(struct nf_logger *logger);
>
> -void nf_log_set(struct net *net, u_int8_t pf,
> +int nf_log_set(struct net *net, u_int8_t pf,
>                 const struct nf_logger *logger);
>  void nf_log_unset(struct net *net, const struct nf_logger *logger);
>
> diff --git a/net/bridge/netfilter/nf_log_bridge.c b/net/bridge/netfilter/nf_log_bridge.c
> index 5d9953a..1663df5 100644
> --- a/net/bridge/netfilter/nf_log_bridge.c
> +++ b/net/bridge/netfilter/nf_log_bridge.c
> @@ -50,8 +50,7 @@ static struct nf_logger nf_bridge_logger __read_mostly = {
>
>  static int __net_init nf_log_bridge_net_init(struct net *net)
>  {
> -       nf_log_set(net, NFPROTO_BRIDGE, &nf_bridge_logger);
> -       return 0;
> +       return nf_log_set(net, NFPROTO_BRIDGE, &nf_bridge_logger);
>  }
>
>  static void __net_exit nf_log_bridge_net_exit(struct net *net)
> diff --git a/net/ipv4/netfilter/nf_log_arp.c b/net/ipv4/netfilter/nf_log_arp.c
> index e7ad950..73599f2 100644
> --- a/net/ipv4/netfilter/nf_log_arp.c
> +++ b/net/ipv4/netfilter/nf_log_arp.c
> @@ -111,8 +111,7 @@ static struct nf_logger nf_arp_logger __read_mostly = {
>
>  static int __net_init nf_log_arp_net_init(struct net *net)
>  {
> -       nf_log_set(net, NFPROTO_ARP, &nf_arp_logger);
> -       return 0;
> +       return nf_log_set(net, NFPROTO_ARP, &nf_arp_logger);
>  }
>
>  static void __net_exit nf_log_arp_net_exit(struct net *net)
> diff --git a/net/ipv4/netfilter/nf_log_ipv4.c b/net/ipv4/netfilter/nf_log_ipv4.c
> index 076aadd..20f2255 100644
> --- a/net/ipv4/netfilter/nf_log_ipv4.c
> +++ b/net/ipv4/netfilter/nf_log_ipv4.c
> @@ -347,8 +347,7 @@ static struct nf_logger nf_ip_logger __read_mostly = {
>
>  static int __net_init nf_log_ipv4_net_init(struct net *net)
>  {
> -       nf_log_set(net, NFPROTO_IPV4, &nf_ip_logger);
> -       return 0;
> +       return nf_log_set(net, NFPROTO_IPV4, &nf_ip_logger);
>  }
>
>  static void __net_exit nf_log_ipv4_net_exit(struct net *net)
> diff --git a/net/ipv6/netfilter/nf_log_ipv6.c b/net/ipv6/netfilter/nf_log_ipv6.c
> index 8dd8696..c1bcf69 100644
> --- a/net/ipv6/netfilter/nf_log_ipv6.c
> +++ b/net/ipv6/netfilter/nf_log_ipv6.c
> @@ -379,8 +379,7 @@ static struct nf_logger nf_ip6_logger __read_mostly = {
>
>  static int __net_init nf_log_ipv6_net_init(struct net *net)
>  {
> -       nf_log_set(net, NFPROTO_IPV6, &nf_ip6_logger);
> -       return 0;
> +       return nf_log_set(net, NFPROTO_IPV6, &nf_ip6_logger);
>  }
>
>  static void __net_exit nf_log_ipv6_net_exit(struct net *net)
> diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
> index aa5847a..30a17d6 100644
> --- a/net/netfilter/nf_log.c
> +++ b/net/netfilter/nf_log.c
> @@ -39,12 +39,12 @@ static struct nf_logger *__find_logger(int pf, const char *str_logger)
>         return NULL;
>  }
>
> -void nf_log_set(struct net *net, u_int8_t pf, const struct nf_logger *logger)
> +int nf_log_set(struct net *net, u_int8_t pf, const struct nf_logger *logger)
>  {
>         const struct nf_logger *log;
>
> -       if (pf == NFPROTO_UNSPEC)
> -               return;
> +       if (pf == NFPROTO_UNSPEC || pf >= ARRAY_SIZE(net->nf.nf_loggers))
> +               return -EOPNOTSUPP;
>
>         mutex_lock(&nf_log_mutex);
>         log = nft_log_dereference(net->nf.nf_loggers[pf]);
> @@ -52,6 +52,8 @@ void nf_log_set(struct net *net, u_int8_t pf, const struct nf_logger *logger)
>                 rcu_assign_pointer(net->nf.nf_loggers[pf], logger);
>
>         mutex_unlock(&nf_log_mutex);
> +
> +       return 0;
>  }
>  EXPORT_SYMBOL(nf_log_set);
>
> --
> 1.9.1
>

Sorry, this patch does not fix any bug.
The subject should be "nf-next".

Regards
Feng
