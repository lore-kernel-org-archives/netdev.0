From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next] mpls: Move reserved label definitions
Date: Wed, 06 May 2015 16:07:09 -0500
Message-ID: <87sib9fm9u.fsf@x220.int.ebiederm.org>
References: <1430841990-2828702-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:47458 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119AbbEFVLh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 17:11:37 -0400
In-Reply-To: <1430841990-2828702-1-git-send-email-tom@herbertland.com> (Tom
	Herbert's message of "Tue, 5 May 2015 09:06:30 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <tom@herbertland.com> writes:

> Move to include/uapi/linux/mpls.h to be externally visibile.

Quick question.

Have you looked to see if any of the BSD's provide any of these
definitions?    I believe the existing macros in this header are
used by tcpdump and are used by the bsds.

I am just thinking if there was already similar definitions in different
unices it would be polite to ensure we have the names in sync.

Eric

> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  include/uapi/linux/mpls.h | 10 ++++++++++
>  net/mpls/af_mpls.c        | 18 +++++++++---------
>  net/mpls/internal.h       | 10 ----------
>  3 files changed, 19 insertions(+), 19 deletions(-)
>
> diff --git a/include/uapi/linux/mpls.h b/include/uapi/linux/mpls.h
> index bc9abfe..0fe6ea5 100644
> --- a/include/uapi/linux/mpls.h
> +++ b/include/uapi/linux/mpls.h
> @@ -31,4 +31,14 @@ struct mpls_label {
>  #define MPLS_LS_TTL_MASK        0x000000FF
>  #define MPLS_LS_TTL_SHIFT       0
>  
> +/* Reserved labels */
> +#define MPLS_LABEL_IPV4_EXPLICIT_NULL	0 /* RFC3032 */
> +#define MPLS_LABEL_ROUTER_ALERT		1 /* RFC3032 */
> +#define MPLS_LABEL_IPV6_EXPLICIT_NULL	2 /* RFC3032 */
> +#define MPLS_LABEL_IMPLICIT_NULL	3 /* RFC3032 */
> +#define MPLS_LABEL_ENTROPY_INDICATOR	7 /* RFC6790 */
> +#define MPLS_LABEL_GAL			13 /* RFC5586 */
> +#define MPLS_LABEL_OAM_ALERT		14 /* RFC3429 */
> +#define MPLS_LABEL_EXTENSION		15 /* RFC7274 */
> +
>  #endif /* _UAPI_MPLS_H */
> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
> index 954810c..b6eb761 100644
> --- a/net/mpls/af_mpls.c
> +++ b/net/mpls/af_mpls.c
> @@ -647,7 +647,7 @@ int nla_get_labels(const struct nlattr *nla,
>  			return -EINVAL;
>  
>  		switch (dec.label) {
> -		case LABEL_IMPLICIT_NULL:
> +		case MPLS_LABEL_IMPLICIT_NULL:
>  			/* RFC3032: This is a label that an LSR may
>  			 * assign and distribute, but which never
>  			 * actually appears in the encapsulation.
> @@ -935,7 +935,7 @@ static int resize_platform_label_table(struct net *net, size_t limit)
>  	}
>  
>  	/* In case the predefined labels need to be populated */
> -	if (limit > LABEL_IPV4_EXPLICIT_NULL) {
> +	if (limit > MPLS_LABEL_IPV4_EXPLICIT_NULL) {
>  		struct net_device *lo = net->loopback_dev;
>  		rt0 = mpls_rt_alloc(lo->addr_len);
>  		if (!rt0)
> @@ -945,7 +945,7 @@ static int resize_platform_label_table(struct net *net, size_t limit)
>  		rt0->rt_via_table = NEIGH_LINK_TABLE;
>  		memcpy(rt0->rt_via, lo->dev_addr, lo->addr_len);
>  	}
> -	if (limit > LABEL_IPV6_EXPLICIT_NULL) {
> +	if (limit > MPLS_LABEL_IPV6_EXPLICIT_NULL) {
>  		struct net_device *lo = net->loopback_dev;
>  		rt2 = mpls_rt_alloc(lo->addr_len);
>  		if (!rt2)
> @@ -973,15 +973,15 @@ static int resize_platform_label_table(struct net *net, size_t limit)
>  	memcpy(labels, old, cp_size);
>  
>  	/* If needed set the predefined labels */
> -	if ((old_limit <= LABEL_IPV6_EXPLICIT_NULL) &&
> -	    (limit > LABEL_IPV6_EXPLICIT_NULL)) {
> -		RCU_INIT_POINTER(labels[LABEL_IPV6_EXPLICIT_NULL], rt2);
> +	if ((old_limit <= MPLS_LABEL_IPV6_EXPLICIT_NULL) &&
> +	    (limit > MPLS_LABEL_IPV6_EXPLICIT_NULL)) {
> +		RCU_INIT_POINTER(labels[MPLS_LABEL_IPV6_EXPLICIT_NULL], rt2);
>  		rt2 = NULL;
>  	}
>  
> -	if ((old_limit <= LABEL_IPV4_EXPLICIT_NULL) &&
> -	    (limit > LABEL_IPV4_EXPLICIT_NULL)) {
> -		RCU_INIT_POINTER(labels[LABEL_IPV4_EXPLICIT_NULL], rt0);
> +	if ((old_limit <= MPLS_LABEL_IPV4_EXPLICIT_NULL) &&
> +	    (limit > MPLS_LABEL_IPV4_EXPLICIT_NULL)) {
> +		RCU_INIT_POINTER(labels[MPLS_LABEL_IPV4_EXPLICIT_NULL], rt0);
>  		rt0 = NULL;
>  	}
>  
> diff --git a/net/mpls/internal.h b/net/mpls/internal.h
> index 693877d..b064c34 100644
> --- a/net/mpls/internal.h
> +++ b/net/mpls/internal.h
> @@ -1,16 +1,6 @@
>  #ifndef MPLS_INTERNAL_H
>  #define MPLS_INTERNAL_H
>  
> -#define LABEL_IPV4_EXPLICIT_NULL	0 /* RFC3032 */
> -#define LABEL_ROUTER_ALERT_LABEL	1 /* RFC3032 */
> -#define LABEL_IPV6_EXPLICIT_NULL	2 /* RFC3032 */
> -#define LABEL_IMPLICIT_NULL		3 /* RFC3032 */
> -#define LABEL_ENTROPY_INDICATOR		7 /* RFC6790 */
> -#define LABEL_GAL			13 /* RFC5586 */
> -#define LABEL_OAM_ALERT			14 /* RFC3429 */
> -#define LABEL_EXTENSION			15 /* RFC7274 */
> -
> -
>  struct mpls_shim_hdr {
>  	__be32 label_stack_entry;
>  };
