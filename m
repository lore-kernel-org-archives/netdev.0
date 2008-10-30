From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH] : Fix compilation warnings in net/netlabel/netlabel_addrlist.c
Date: Thu, 30 Oct 2008 09:39:59 -0400
Message-ID: <200810300939.59145.paul.moore@hp.com>
References: <ea11fea30810290106u3f92268q62226da65db6f6a4@mail.gmail.com> <200810300812.39810.paul.moore@hp.com> <ea11fea30810300633m5a99d4a1k9c0b9a2aa241ecb1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: "Manish Katiyar" <mkatiyar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:30070 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754135AbYJ3NkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 09:40:03 -0400
In-Reply-To: <ea11fea30810300633m5a99d4a1k9c0b9a2aa241ecb1@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 30 October 2008 9:33:55 am Manish Katiyar wrote:
> Hi Paul,
>
> Below is the updated patch.
>
> Enable netlabel auditing functions only when CONFIG_AUDIT is set
>
> Signed-off-by: Manish Katiyar <mkatiyar@gmail.com>

Thanks a lot, I'll apply this and send a pull request later today.

> ---
>  net/netlabel/netlabel_addrlist.c |    2 ++
>  net/netlabel/netlabel_addrlist.h |   22 ++++++++++++++++++++++
>  2 files changed, 24 insertions(+), 0 deletions(-)
>
> diff --git a/net/netlabel/netlabel_addrlist.c
> b/net/netlabel/netlabel_addrlist.c index b0925a3..249f6b9 100644
> --- a/net/netlabel/netlabel_addrlist.c
> +++ b/net/netlabel/netlabel_addrlist.c
> @@ -315,6 +315,7 @@ struct netlbl_af6list
> *netlbl_af6list_remove(const struct in6_addr *addr,
>   * Audit Helper Functions
>   */
>
> +#ifdef CONFIG_AUDIT
>  /**
>   * netlbl_af4list_audit_addr - Audit an IPv4 address
>   * @audit_buf: audit buffer
> @@ -386,3 +387,4 @@ void netlbl_af6list_audit_addr(struct
> audit_buffer *audit_buf,
>  	}
>  }
>  #endif /* IPv6 */
> +#endif /* CONFIG_AUDIT */
> diff --git a/net/netlabel/netlabel_addrlist.h
> b/net/netlabel/netlabel_addrlist.h index 0242bea..3212965 100644
> --- a/net/netlabel/netlabel_addrlist.h
> +++ b/net/netlabel/netlabel_addrlist.h
> @@ -120,9 +120,19 @@ struct netlbl_af4list
> *netlbl_af4list_search(__be32 addr, struct netlbl_af4list
> *netlbl_af4list_search_exact(__be32 addr, __be32 mask,
>  						   struct list_head *head);
> +
> +#ifdef CONFIG_AUDIT
>  void netlbl_af4list_audit_addr(struct audit_buffer *audit_buf,
>  			       int src, const char *dev,
>  			       __be32 addr, __be32 mask);
> +#else
> +static inline void netlbl_af4list_audit_addr(struct audit_buffer
> *audit_buf, +			       int src, const char *dev,
> +			       __be32 addr, __be32 mask)
> +{
> +	return;
> +}
> +#endif
>
>  #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
>
> @@ -179,11 +189,23 @@ struct netlbl_af6list
> *netlbl_af6list_search(const struct in6_addr *addr,
>  struct netlbl_af6list *netlbl_af6list_search_exact(const struct
> in6_addr *addr, const struct in6_addr *mask,
>  						   struct list_head *head);
> +
> +#ifdef CONFIG_AUDIT
>  void netlbl_af6list_audit_addr(struct audit_buffer *audit_buf,
>  			       int src,
>  			       const char *dev,
>  			       const struct in6_addr *addr,
>  			       const struct in6_addr *mask);
> +#else
> +static inline void netlbl_af6list_audit_addr(struct audit_buffer
> *audit_buf, +			       int src,
> +			       const char *dev,
> +			       const struct in6_addr *addr,
> +			       const struct in6_addr *mask)
> +{
> +	return;
> +}
> +#endif
>  #endif /* IPV6 */
>
>  #endif



-- 
paul moore
linux @ hp
