From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [RFC PATCH] ipv6: Split from and expires field in dst_entry out of union [net-next]
Date: Wed, 20 Feb 2013 10:55:35 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7157@saturn3.aculab.com>
References: <1361231718.19353.117.camel@edumazet-glaptop> <1361305694-8303-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <eric.dumazet@gmail.com>, "David Miller" <davem@davemloft.net>,
	"Gao feng" <gaofeng@cn.fujitsu.com>, "Jiri Bohac" <jbohac@suse.cz>
To: "Neil Horman" <nhorman@tuxdriver.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:35640 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S934457Ab3BTK4e convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2013 05:56:34 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 30554-02 for <netdev@vger.kernel.org>;
 Wed, 20 Feb 2013 10:56:31 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1361305694-8303-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  static inline void rt6_clean_expires(struct rt6_info *rt)
>  {
> -	if (!(rt->rt6i_flags & RTF_EXPIRES) && rt->dst.from)
> +	if (!rt->rt6i_flags & RTF_EXPIRES)
>  		dst_release(rt->dst.from);
> 
>  	rt->rt6i_flags &= ~RTF_EXPIRES;
>  	rt->dst.from = NULL;
> +	rt->dst.expires = 0;
>  }
> 
>  static inline void rt6_set_expires(struct rt6_info *rt, unsigned long expires)
>  {
> -	if (!(rt->rt6i_flags & RTF_EXPIRES) && rt->dst.from)
> +	if (!rt->rt6i_flags & RTF_EXPIRES)
>  		dst_release(rt->dst.from);
> 
>  	rt->rt6i_flags |= RTF_EXPIRES;
> +	rt->dst.from = NULL;
>  	rt->dst.expires = expires;
>  }
> 
>  static inline void rt6_update_expires(struct rt6_info *rt, int timeout)
>  {
>  	if (!(rt->rt6i_flags & RTF_EXPIRES)) {
> -		if (rt->dst.from)
> -			dst_release(rt->dst.from);
> +		dst_release(rt->dst.from);
>  		/* dst_set_expires relies on expires == 0
>  		 * if it has not been set previously.
>  		 */
>  		rt->dst.expires = 0;
> +		rt6->dst.from = NULL;
>  	}

Aren't there also problems with setting and clearing RTF_EXPIRES?
Since that flag looks as though it was the descriminant for the union
it probably isn't needed - provided dst.expires is never 0 when valid.

	David
