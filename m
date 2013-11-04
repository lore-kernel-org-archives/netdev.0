From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] ipv6: enable IPV6_FLOWLABEL_MGR for getsockopt
Date: Mon, 4 Nov 2013 18:46:49 +0100
Message-ID: <20131104174649.GC8832@order.stressinduktion.org>
References: <1383411524-16743-1-git-send-email-florent.fourcot@enst-bretagne.fr> <20131104000425.GB8832@order.stressinduktion.org> <5277D4AD.10308@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:48839 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751707Ab3KDRqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 12:46:50 -0500
Content-Disposition: inline
In-Reply-To: <5277D4AD.10308@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 04, 2013 at 06:09:01PM +0100, Florent Fourcot wrote:
> 
> > We should take ip6_fl_lock here, otherwise expires extraction races with
> > the garbage collector (which can update it). There seem to be some other
> > unsafe places, e.g. fl6_renew.
> > 
> 
> I will fix it, and for fl6_renew too.

Thanks!

> >> +			freq->flr_label = sfl->fl->label;
> >> +			freq->flr_dst = sfl->fl->dst;
> >> +			freq->flr_share = sfl->fl->share;
> >> +			freq->flr_expires = (sfl->fl->expires - jiffies) / HZ;
> >> +			freq->flr_linger = sfl->fl->linger / HZ;
> >> +
> >> +			rcu_read_unlock_bh();
> >> +			return 0;
> >> +		}
> >> +	}
> >> +	rcu_read_unlock_bh();
> >> +
> >> +	return 0;
> > 
> > Maybe return -EINVAL for not found?
> > 
> 
> I don't like -EINVAL for this case, since the user can not know if there
> are no label or if the request has bad parameters. Could -ENOMSG be OK?

-ENOMSG or we already return -ENOENT from the same setsockopt. I would go with
ENOENT.

Greetings,

  Hannes
