From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH] : Fix compilation warnings in net/netlabel/netlabel_addrlist.c
Date: Wed, 29 Oct 2008 09:49:09 -0400
Message-ID: <200810290949.09108.paul.moore@hp.com>
References: <ea11fea30810290106u3f92268q62226da65db6f6a4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org
To: "Manish Katiyar" <mkatiyar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:27027 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753860AbYJ2NtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 09:49:12 -0400
In-Reply-To: <ea11fea30810290106u3f92268q62226da65db6f6a4@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 29 October 2008 4:06:09 am Manish Katiyar wrote:
> Below patch fixes the following warning.
> net/netlabel/netlabel_addrlist.c:335: warning: unused variable 'dir'
> net/netlabel/netlabel_addrlist.c:369: warning: unused variable 'dir'
>
>
> Signed-off-by: Manish Katiyar <mkatiyar@gmail.com>

Hi Manish,

Good catch, I ran compile tests with different SECURITY/NETLABEL/IPV6 
options enabled/disabled but forgot about AUDIT.  I appreciate your 
help finding this and submitting a possible solution but I think the 
better approach would be to conditionally compile out the 
netlbl_af{4,6}list_audit_addr() functions similarly to what we do with 
several of the NetLabel kernel API functions in include/net/netlabel.h, 
see netlbl_enabled() for a simple example.

If you have the time to revise this patch that would be great, just CC 
me on the posting and I'll look it over.  If you don't have time that 
is okay too, just let me know so I can fix it.

Thanks!

> ---
>  net/netlabel/netlabel_addrlist.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
>
> diff --git a/net/netlabel/netlabel_addrlist.c
> b/net/netlabel/netlabel_addrlist.c index b0925a3..65fbec1 100644
> --- a/net/netlabel/netlabel_addrlist.c
> +++ b/net/netlabel/netlabel_addrlist.c
> @@ -332,7 +332,9 @@ void netlbl_af4list_audit_addr(struct
> audit_buffer *audit_buf,
>  					__be32 addr, __be32 mask)
>  {
>  	u32 mask_val = ntohl(mask);
> +#ifdef CONFIG_AUDIT
>  	char *dir = (src ? "src" : "dst");
> +#endif
>
>  	if (dev != NULL)
>  		audit_log_format(audit_buf, " netif=%s", dev);
> @@ -366,7 +368,9 @@ void netlbl_af6list_audit_addr(struct
> audit_buffer *audit_buf,
>  				 const struct in6_addr *addr,
>  				 const struct in6_addr *mask)
>  {
> +#ifdef CONFIG_AUDIT
>  	char *dir = (src ? "src" : "dst");
> +#endif
>
>  	if (dev != NULL)
>  		audit_log_format(audit_buf, " netif=%s", dev);



-- 
paul moore
linux @ hp
