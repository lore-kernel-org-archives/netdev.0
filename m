From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] ipv6: Split from and expires field in dst_entry out
 of union [net-next]
Date: Tue, 19 Feb 2013 13:17:45 -0800
Message-ID: <1361308665.19353.161.camel@edumazet-glaptop>
References: <1361231718.19353.117.camel@edumazet-glaptop>
	 <1361305694-8303-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Gao feng <gaofeng@cn.fujitsu.com>, Jiri Bohac <jbohac@suse.cz>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:48759 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758582Ab3BSVRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 16:17:49 -0500
Received: by mail-pa0-f43.google.com with SMTP id bh2so3662008pad.16
        for <netdev@vger.kernel.org>; Tue, 19 Feb 2013 13:17:49 -0800 (PST)
In-Reply-To: <1361305694-8303-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-02-19 at 15:28 -0500, Neil Horman wrote:

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
>  

Sorry you didnt really address the problem, only reduce the race window.
