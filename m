From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next 01/11] ipv6: skb_put_zero() used to optimize
 code
Date: Wed, 14 Jun 2017 21:01:32 +0200
Message-ID: <1497466892.9377.5.camel@sipsolutions.net>
References: <1497451026-3923-1-git-send-email-cugyly@163.com>
         <20170614084434.3342671d@xeon-e3> (sfid-20170614_174449_128728_DD5F5738)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: Stephen Hemminger <stephen@networkplumber.org>,
        yuan linyu <cugyly@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:40876 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751598AbdFNTBg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 15:01:36 -0400
In-Reply-To: <20170614084434.3342671d@xeon-e3> (sfid-20170614_174449_128728_DD5F5738)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-06-14 at 08:44 -0700, Stephen Hemminger wrote:
> 
> >  	memcpy(skb_put(skb, sizeof(ra)), ra, sizeof(ra));
> >  
> > -	hdr = (struct mld_msg *) skb_put(skb, sizeof(struct
> > mld_msg));
> > -	memset(hdr, 0, sizeof(struct mld_msg));
> > +	hdr = (struct mld_msg *) skb_put_zero(skb, sizeof(struct
> > mld_msg));
> 
> Why does skb_put_zero return char * instead of void *?
> If returned void * it would save having to add lots of casts.
> 
> One could even go farther by making skb_put_zero a macro and
> use typeof().

I just copied it from skb_put() - you could ask the same there? :)

No objection to changing it though.

johannes
