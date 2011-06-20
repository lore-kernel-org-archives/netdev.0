From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH net-next] ip: introduce ip_is_fragment helper inline function
Date: Mon, 20 Jun 2011 12:35:53 -0300
Message-ID: <4DFF68D9.4000005@redhat.com>
References: <1308334091-10031-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34743 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751592Ab1FTPf5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 11:35:57 -0400
In-Reply-To: <1308334091-10031-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/2011 03:08 PM, Paul Gortmaker wrote:
> There are enough instances of this:
> 
>     iph->frag_off & htons(IP_MF | IP_OFFSET)
> 
> that a helper function is probably warranted.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---
[...]
> diff --git a/include/net/ip.h b/include/net/ip.h
> index e9ea7c7..114a152 100644
> --- a/include/net/ip.h
> +++ b/include/net/ip.h
> @@ -250,6 +250,11 @@ int ip_decrease_ttl(struct iphdr *iph)
>  	return --iph->ttl;
>  }
>  
> +static inline int ip_is_fragment(const struct iphdr *iph)
> +{
> +	return iph->frag_off & htons(IP_MF | IP_OFFSET);
> +}
> +

Do we really need 'inline' there?

fbl
