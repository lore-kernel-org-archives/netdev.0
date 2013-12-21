From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v4 2/2] libnetfilter_queue: add support for UID/GID
 socket info
Date: Sat, 21 Dec 2013 12:38:04 +0100
Message-ID: <20131221113804.GA17964@localhost>
References: <1387556934-7372-1-git-send-email-valentina.giusti@bmw-carit.de>
 <1387556934-7372-3-git-send-email-valentina.giusti@bmw-carit.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	jpa@google.com, fw@strnel.de, daniel.wagner@bmw-carit.de
To: valentina.giusti@bmw-carit.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39413 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751756Ab3LULiM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Dec 2013 06:38:12 -0500
Content-Disposition: inline
In-Reply-To: <1387556934-7372-3-git-send-email-valentina.giusti@bmw-carit.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Dec 20, 2013 at 05:28:54PM +0100, valentina.giusti@bmw-carit.de wrote:
[...]
> diff --git a/include/libnetfilter_queue/linux_nfnetlink_queue.h b/include/libnetfilter_queue/linux_nfnetlink_queue.h
> index 81a485b..884ab0e 100644
> --- a/include/libnetfilter_queue/linux_nfnetlink_queue.h
> +++ b/include/libnetfilter_queue/linux_nfnetlink_queue.h
> @@ -50,6 +50,8 @@ enum nfqnl_attr_type {
>  	NFQA_CAP_LEN,                   /* __u32 length of captured packet */
>  	NFQA_SKB_INFO,                  /* __u32 skb meta information */
>  
> +	NFQA_UID,			/* __u32 sk uid */
> +	NFQA_GID,			/* __u32 sk gid */

This update is wrong. See below the reason why.

>  	__NFQA_MAX
>  };
>  #define NFQA_MAX (__NFQA_MAX - 1)
> @@ -101,7 +103,8 @@ enum nfqnl_attr_config {
>  #define NFQA_CFG_F_FAIL_OPEN		(1 << 0)
>  #define NFQA_CFG_F_CONNTRACK		(1 << 1)
>  #define NFQA_CFG_F_GSO			(1 << 2)
> -#define NFQA_CFG_F_MAX			(1 << 3)
> +#define NFQA_CFG_F_UID_GID		(1 << 3)
> +#define NFQA_CFG_F_MAX			(1 << 4)
>  
>  /* flags for NFQA_SKB_INFO */
>  /* packet appears to have wrong checksums, but they are ok */
> diff --git a/include/linux/netfilter/nfnetlink_queue.h b/include/linux/netfilter/nfnetlink_queue.h
> index a2308ae..22f5d45 100644
> --- a/include/linux/netfilter/nfnetlink_queue.h
> +++ b/include/linux/netfilter/nfnetlink_queue.h
> @@ -46,6 +46,9 @@ enum nfqnl_attr_type {
>  	NFQA_CT_INFO,			/* enum ip_conntrack_info */
>  	NFQA_CAP_LEN,			/* __u32 length of captured packet */
>  	NFQA_SKB_INFO,			/* __u32 skb meta information */
> +	NFQA_EXP,			/* nf_conntrack_netlink.h */
> +	NFQA_UID,			/* __u32 sk uid */
> +	NFQA_GID,			/* __u32 sk gid */

You have manually updated libnetfilter_queue/linux_nfnetlink_queue.h,
but you forgot to include NFQA_EXP. The result is that your
nfq_get_uid() returns the NFQA_EXP attribute and nfq_get_gid() returns
the NFQA_UID attribute.

You should have noticed it with a simple run of utils/nfqnl_test run
and a couple of printf to test it. I'm afraid that you're not giving
sufficient testing to your patches.

Fix it and resubmit, thanks.
