From: Joe Perches <joe@perches.com>
Subject: Re: [rfc] suspicious indentation in do_tcp_setsockopt
Date: Wed, 04 Sep 2013 21:43:16 -0700
Message-ID: <1378356196.1787.74.camel@joe-AO722>
References: <20130905042045.GD15824@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>
To: Dave Jones <davej@redhat.com>, Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:33381 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753009Ab3IEEnY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Sep 2013 00:43:24 -0400
In-Reply-To: <20130905042045.GD15824@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Adding Yuchung Cheng and Neal Cardwell as the
 author and acker of the patch)

On Thu, 2013-09-05 at 00:20 -0400, Dave Jones wrote:
> What's the intent here ?
> 
> This ?

I think the first is most likely.

> 
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index b2f6c74..95544e4 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2454,10 +2454,11 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
>  	case TCP_THIN_DUPACK:
>  		if (val < 0 || val > 1)
>  			err = -EINVAL;
> -		else
> +		else {
>  			tp->thin_dupack = val;
>  			if (tp->thin_dupack)
>  				tcp_disable_early_retrans(tp);
> +		}
>  		break;
>  
>  	case TCP_REPAIR:
> 
> Or this ...
> 
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index b2f6c74..187c5a4 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2456,8 +2456,9 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
>  			err = -EINVAL;
>  		else
>  			tp->thin_dupack = val;
> -			if (tp->thin_dupack)
> -				tcp_disable_early_retrans(tp);
> +
> +		if (tp->thin_dupack)
> +			tcp_disable_early_retrans(tp);
>  		break;
>  
>  	case TCP_REPAIR:
> 
> 
> I'll submit the right patch in the right form once I know what was intended.
> 
> The former seems more 'correct' to me, but I'm unsure if that could break something.
> 
> 	Dave
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
