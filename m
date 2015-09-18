From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] iplink_geneve: add UDP destination port configuration at
 link creation
Date: Fri, 18 Sep 2015 10:26:18 -0400
Message-ID: <20150918142618.GA18191@tuxdriver.com>
References: <1442518065-23294-1-git-send-email-linville@tuxdriver.com>
 <1442522989.7946.4.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41255 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752902AbbIROaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 10:30:17 -0400
Content-Disposition: inline
In-Reply-To: <1442522989.7946.4.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 17, 2015 at 01:49:49PM -0700, Eric Dumazet wrote:
> On Thu, 2015-09-17 at 15:27 -0400, John W. Linville wrote:
> > Signed-off-by: John W. Linville <linville@tuxdriver.com>
> > ---
> 
> >  }
> >  
> > @@ -150,6 +159,10 @@ static void geneve_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
> >  		else
> >  			fprintf(f, "tos %#x ", tos);
> >  	}
> > +
> > +	if (tb[IFLA_GENEVE_PORT])
> > +		fprintf(f, "dstport %u ",
> > +			ntohs(rta_getattr_u16(tb[IFLA_GENEVE_PORT])));
> 
> This looks strange.
> 
> Kernel does :
> 
> if (nla_put_u16(skb, IFLA_GENEVE_PORT, ntohs(geneve->dst_port)))
>         goto nla_put_failure;

Indeed, you are right.  I had essentially copied some vxlan code when
I did my version of adding the port attribute, and didn't take much
care when adapting that code for the version that actually got merged.

The current geneve code is using host byte-order for the UDP port in
the netlink messages.  But, I see that vxlan, gre, iptnl, etc are using
network byte order for specifying UDP ports in their netlink stuff.
Should geneve follow that practice as well?  Or does it matter?

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
