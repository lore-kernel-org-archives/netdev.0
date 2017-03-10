From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 2/2] mpls: allow TTL propagation from IP
 packets to be configured
Date: Thu, 9 Mar 2017 19:54:23 -0700
Message-ID: <3a3b0cfe-106c-88ee-e225-0df1458aab4b@cumulusnetworks.com>
References: <1485808575-16852-1-git-send-email-rshearma@brocade.com>
 <1488933990-14490-1-git-send-email-rshearma@brocade.com>
 <1488933990-14490-3-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        roopa <roopa@cumulusnetworks.com>
To: Robert Shearman <rshearma@brocade.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35531 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754139AbdCJCy1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 21:54:27 -0500
Received: by mail-pf0-f178.google.com with SMTP id j5so36145946pfb.2
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 18:54:26 -0800 (PST)
In-Reply-To: <1488933990-14490-3-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/7/17 5:46 PM, Robert Shearman wrote:
> @@ -78,6 +70,29 @@ static int mpls_xmit(struct sk_buff *skb)
>  
>  	tun_encap_info = mpls_lwtunnel_encap(dst->lwtstate);
>  
> +	/* Obtain the ttl */
> +	if (dst->ops->family == AF_INET) {
> +		if (tun_encap_info->ttl_propagate == MPLS_TTL_PROP_DISABLED)
> +			ttl = tun_encap_info->default_ttl;
> +		else if (tun_encap_info->ttl_propagate == MPLS_TTL_PROP_DEFAULT &&
> +			 !net->mpls.ip_ttl_propagate)
> +			ttl = net->mpls.default_ttl;
> +		else
> +			ttl = ip_hdr(skb)->ttl;

After staring at that for a while, an explanation above this if {} else
{} section on the ttl selection will be very helpful.
