From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [ovs-dev] [RFC PATCH 1/5] netfilter: Remove IP_CT_NEW_REPLY
 definition.
Date: Wed, 21 Oct 2015 10:33:23 +0200
Message-ID: <20151021083323.GB15539@pox.localdomain>
References: <1445379629-112880-1-git-send-email-jrajahalme@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	netfilter-devel@vger.kernel.org
To: Jarno Rajahalme <jrajahalme@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:35218 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932166AbbJUId0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 04:33:26 -0400
Received: by wicll6 with SMTP id ll6so79788578wic.0
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 01:33:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1445379629-112880-1-git-send-email-jrajahalme@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Copying netfilter-devel]

On 10/20/15 at 03:20pm, Jarno Rajahalme wrote:
> Remove the definition of IP_CT_NEW_REPLY as it does not make sense.
> This allows the definition of IP_CT_NUMBER to be simplified as well.
> 
> Signed-off-by: Jarno Rajahalme <jrajahalme@nicira.com>
> ---
>  include/uapi/linux/netfilter/nf_conntrack_common.h | 7 ++++---
>  net/openvswitch/conntrack.c                        | 2 --
>  2 files changed, 4 insertions(+), 5 deletions(-)
> 
> diff --git a/include/uapi/linux/netfilter/nf_conntrack_common.h b/include/uapi/linux/netfilter/nf_conntrack_common.h
> index 319f471..e0aebc8 100644
> --- a/include/uapi/linux/netfilter/nf_conntrack_common.h
> +++ b/include/uapi/linux/netfilter/nf_conntrack_common.h
> @@ -20,9 +20,10 @@ enum ip_conntrack_info {
>  
>  	IP_CT_ESTABLISHED_REPLY = IP_CT_ESTABLISHED + IP_CT_IS_REPLY,
>  	IP_CT_RELATED_REPLY = IP_CT_RELATED + IP_CT_IS_REPLY,
> -	IP_CT_NEW_REPLY = IP_CT_NEW + IP_CT_IS_REPLY,	
> -	/* Number of distinct IP_CT types (no NEW in reply dirn). */
> -	IP_CT_NUMBER = IP_CT_IS_REPLY * 2 - 1
> +	/* No IP_CT_NEW_REPLY */
> +
> +	/* Number of distinct IP_CT types. */
> +	IP_CT_NUMBER
>  };

I understand what you are doing here but this is part of the published
UAPI and removing this might break compilation of a user application
even if the definition is not used right now. It's probably safer to
leave the definition and obsolete it with a comment.
