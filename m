From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v1 3/4] vxlan: add ipv6 support
Date: Tue, 02 Apr 2013 09:39:49 +0800
Message-ID: <1364866789.17029.2.camel@cr0>
References: <1364708625-29063-1-git-send-email-amwang@redhat.com>
	 <1364708625-29063-3-git-send-email-amwang@redhat.com>
	 <20130401131450.5d6bbc1e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49026 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759724Ab3DBBj4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Apr 2013 21:39:56 -0400
In-Reply-To: <20130401131450.5d6bbc1e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-01 at 13:14 -0700, Stephen Hemminger wrote:
> On Sun, 31 Mar 2013 13:43:44 +0800
> Cong Wang <amwang@redhat.com> wrote:
> 
> >  	/* Need to drop RTNL to call multicast leave */
> >  	rtnl_unlock();
> > -	lock_sock(sk);
> > -	err = ip_mc_leave_group(sk, &mreq);
> > +	if (vxlan->gaddr.proto == htons(ETH_P_IP)) {
> > +		lock_sock(sk);
> > +		err = ip_mc_leave_group(sk, &mreq);
> > +	} else {
> > +#if IS_ENABLED(CONFIG_IPV6)
> > +		lock_sock(sk);
> > +		err = ipv6_sock_mc_drop(sk, vxlan->link, &vxlan->gaddr.ip6);
> > +#endif
> > +	}
> >  	release_sock(sk);
> 
> Since both v4 and v6 need socket locked why not?
> 
> 	rtnl_unlock();
> 	lock_sock(sk);
> 	if (vxlan->gaddr.proto == htons(ETH_P_IP)) 
> 		err = ip_mc_leave_group(sk, &mreq);
> if IS_ENABLED(CONFIG_IPV6)
> 	else
> 		err = ipv6_sock_mc_drop(sk, vxlan->link, &vxlan->gaddr.ip6);
> #endif
> 
>   	release_sock(sk);

Oh, of course, I missed that...

Thanks!
