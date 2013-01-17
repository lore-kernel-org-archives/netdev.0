From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next 1/2] xfrm: replace rwlock on xfrm_state_afinfo
 with rcu
Date: Thu, 17 Jan 2013 14:22:46 +0800
Message-ID: <1358403766.3855.21.camel@cr0>
References: <1358323506-19571-1-git-send-email-amwang@redhat.com>
	 <50F6B1DC.4030307@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53314 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750927Ab3AQGX7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2013 01:23:59 -0500
In-Reply-To: <50F6B1DC.4030307@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-16 at 22:57 +0900, YOSHIFUJI Hideaki wrote:
> Cong Wang wrote:
> >  
> >  static void xfrm_state_unlock_afinfo(struct xfrm_state_afinfo *afinfo)
> > -	__releases(xfrm_state_afinfo_lock)
> >  {
> > -	write_unlock_bh(&xfrm_state_afinfo_lock);
> > +	spin_unlock_bh(&xfrm_state_afinfo_lock);
> >  }
> >  
> >  int xfrm_register_type(const struct xfrm_type *type, unsigned short family)
> 
> Why removing __releases() hint?

There is no __acquires matched:
% git grep __acquires -- net/xfrm 
<nothing output>
