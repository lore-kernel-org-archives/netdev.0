From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] netlink: fix overrun in attribute iteration
Date: Fri, 12 Sep 2008 02:35:23 +0200
Message-ID: <20080912003522.GN20815@postel.suug.ch>
References: <20080911205933.GA20032@localhost.localdomain> <20080911.150434.99620481.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vegard.nossum@gmail.com, netdev@vger.kernel.org,
	penberg@cs.helsinki.fi, mingo@elte.hu, viro@zeniv.linux.org.uk,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755795AbYILAfV@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080911.150434.99620481.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller <davem@davemloft.net> 2008-09-11 15:04
> From: Vegard Nossum <vegard.nossum@gmail.com>
> Thomas, please review.
> 
> > diff --git a/include/net/netlink.h b/include/net/netlink.h
> > index 18024b8..208fe5a 100644
> > --- a/include/net/netlink.h
> > +++ b/include/net/netlink.h
> > @@ -702,7 +702,7 @@ static inline int nla_len(const struct nlattr *nla)
> >   */
> >  static inline int nla_ok(const struct nlattr *nla, int remaining)
> >  {
> > -	return remaining >= sizeof(*nla) &&
> > +	return remaining >= (int) sizeof(*nla) &&
> >  	       nla->nla_len >= sizeof(*nla) &&
> >  	       nla->nla_len <= remaining;
> >  }

Very nice catch, would never have thought of that.
