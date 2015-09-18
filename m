From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] iplink_geneve: add UDP destination port configuration
 at link creation
Date: Fri, 18 Sep 2015 07:45:24 -0700
Message-ID: <1442587524.7946.21.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1442518065-23294-1-git-send-email-linville@tuxdriver.com>
	 <1442522989.7946.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150918142618.GA18191@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35861 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754409AbbIROp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 10:45:27 -0400
Received: by padhk3 with SMTP id hk3so53005329pad.3
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 07:45:26 -0700 (PDT)
In-Reply-To: <20150918142618.GA18191@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-09-18 at 10:26 -0400, John W. Linville wrote:
> On Thu, Sep 17, 2015 at 01:49:49PM -0700, Eric Dumazet wrote:
> > On Thu, 2015-09-17 at 15:27 -0400, John W. Linville wrote:
> > > Signed-off-by: John W. Linville <linville@tuxdriver.com>
> > > ---
> > 
> > >  }
> > >  
> > > @@ -150,6 +159,10 @@ static void geneve_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
> > >  		else
> > >  			fprintf(f, "tos %#x ", tos);
> > >  	}
> > > +
> > > +	if (tb[IFLA_GENEVE_PORT])
> > > +		fprintf(f, "dstport %u ",
> > > +			ntohs(rta_getattr_u16(tb[IFLA_GENEVE_PORT])));
> > 
> > This looks strange.
> > 
> > Kernel does :
> > 
> > if (nla_put_u16(skb, IFLA_GENEVE_PORT, ntohs(geneve->dst_port)))
> >         goto nla_put_failure;
> 
> Indeed, you are right.  I had essentially copied some vxlan code when
> I did my version of adding the port attribute, and didn't take much
> care when adapting that code for the version that actually got merged.
> 
> The current geneve code is using host byte-order for the UDP port in
> the netlink messages.  But, I see that vxlan, gre, iptnl, etc are using
> network byte order for specifying UDP ports in their netlink stuff.
> Should geneve follow that practice as well?  Or does it matter?

It might be too late to change the ABI, as geneve is in linux-4.2

Keep current host order in netlink messages and respin your iproute2
patch, and maybe add a comment to explain difference for a casual
reader ?

Thanks !
