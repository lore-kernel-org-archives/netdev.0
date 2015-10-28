From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/2] mpls: fix forwarding using v4/v6 explicit
 null
Date: Tue, 27 Oct 2015 18:22:42 -0700
Message-ID: <56302362.2050901@cumulusnetworks.com>
References: <1445906256-14927-1-git-send-email-rshearma@brocade.com> <1445906256-14927-2-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34200 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754996AbbJ1BWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 21:22:43 -0400
Received: by padhk11 with SMTP id hk11so239203534pad.1
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 18:22:43 -0700 (PDT)
In-Reply-To: <1445906256-14927-2-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/15, 5:37 PM, Robert Shearman wrote:
> Fill in the via address length for the predefined IPv4 and IPv6
> explicit-null label routes.
>
> Fixes: f8efb73c97e2 ("mpls: multipath route support")
> Signed-off-by: Robert Shearman <rshearma@brocade.com>
> ---
>  net/mpls/af_mpls.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
> index cc972e30355b..1c58662db4b2 100644
> --- a/net/mpls/af_mpls.c
> +++ b/net/mpls/af_mpls.c
> @@ -1345,6 +1345,7 @@ static int resize_platform_label_table(struct net *net, size_t limit)
>  		rt0->rt_protocol = RTPROT_KERNEL;
>  		rt0->rt_payload_type = MPT_IPV4;
>  		rt0->rt_nh->nh_via_table = NEIGH_LINK_TABLE;
> +		rt0->rt_nh->nh_via_alen = lo->addr_len;
>  		memcpy(rt0->rt_nh->nh_via, lo->dev_addr, lo->addr_len);
>  	}
>  	if (limit > MPLS_LABEL_IPV6NULL) {
> @@ -1356,6 +1357,7 @@ static int resize_platform_label_table(struct net *net, size_t limit)
>  		rt2->rt_protocol = RTPROT_KERNEL;
>  		rt2->rt_payload_type = MPT_IPV6;
>  		rt2->rt_nh->nh_via_table = NEIGH_LINK_TABLE;
> +		rt2->rt_nh->nh_via_alen = lo->addr_len;
>  		memcpy(rt2->rt_nh->nh_via, lo->dev_addr, lo->addr_len);
>  	}
>  
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
