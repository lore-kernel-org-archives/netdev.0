From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 2/4] net: mpls: change mpls_route layout
Date: Mon, 27 Mar 2017 19:04:07 -0500
Message-ID: <87mvc6e07c.fsf@xmission.com>
References: <1490461408-9551-1-git-send-email-dsa@cumulusnetworks.com>
        <1490461408-9551-3-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        rshearma@brocade.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:50744 "EHLO
        out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753556AbdC1B31 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 21:29:27 -0400
In-Reply-To: <1490461408-9551-3-git-send-email-dsa@cumulusnetworks.com> (David
        Ahern's message of "Sat, 25 Mar 2017 10:03:26 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern <dsa@cumulusnetworks.com> writes:

> diff --git a/net/mpls/internal.h b/net/mpls/internal.h
> index 66f388ba2d49..302d48f54b57 100644
> --- a/net/mpls/internal.h
> +++ b/net/mpls/internal.h
> @@ -64,7 +64,6 @@ struct mpls_dev {
>  struct sk_buff;
>  
>  #define LABEL_NOT_SPECIFIED (1 << 20)
> -#define MAX_NEW_LABELS 2
>  
>  /* This maximum ha length copied from the definition of struct neighbour */
>  #define VIA_ALEN_ALIGN sizeof(unsigned long)
> @@ -84,12 +83,25 @@ enum mpls_payload_type {
>  struct mpls_nh { /* next hop label forwarding entry */
>  	struct net_device __rcu *nh_dev;
>  	unsigned int		nh_flags;
> -	u32			nh_label[MAX_NEW_LABELS];
>  	u8			nh_labels;
>  	u8			nh_via_alen;
>  	u8			nh_via_table;
> +	/* u8 hole */

This hole probably be better documented with:
	u8			nh_reserved1;
> +	u32			nh_label[0];
>  };

Eric
