From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCHv2 iproute2 1/2] lib/libnetlink: re malloc buff if size is
 not enough
Date: Tue, 19 Sep 2017 13:48:08 +0200
Message-ID: <20170919114808.pisr2lqenhtyisyj@unicorn.suse.cz>
References: <1505296780-8444-1-git-send-email-liuhangbin@gmail.com>
 <1505296780-8444-2-git-send-email-liuhangbin@gmail.com>
 <20170918075504.gdx4q7je5uneefgg@unicorn.suse.cz>
 <20170919030520.GL5465@leo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Phil Sutter <phil@nwl.cc>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:32854 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751753AbdISLsO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 19 Sep 2017 07:48:14 -0400
Content-Disposition: inline
In-Reply-To: <20170919030520.GL5465@leo.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 19, 2017 at 11:05:20AM +0800, Hangbin Liu wrote:
> On Mon, Sep 18, 2017 at 09:55:05AM +0200, Michal Kubecek wrote:
> > > @@ -471,19 +516,23 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
> > >  
> > >  				if (h->nlmsg_type == NLMSG_ERROR) {
> > >  					rtnl_dump_error(rth, h);
> > > +					free(buf);
> > >  					return -1;
> > >  				}
> > >  
> > >  				if (!rth->dump_fp) {
> > >  					err = a->filter(&nladdr, h, a->arg1);
> > > -					if (err < 0)
> > > +					if (err < 0) {
> > > +						free(buf);
> > >  						return err;
> > > +					}
> > >  				}
> > >  
> > >  skip_it:
> > >  				h = NLMSG_NEXT(h, msglen);
> > >  			}
> > >  		}
> > > +		free(buf);
> > 
> > We only free the last buffer returned by rtnl_recvmsg() this way.
> > IMHO this free(buf) should be moved inside the loop.
> 
> Do you mean the outside while loop or the for loop? I think we could
> not put it inside the for loop, because we may need the buf multi
> times based on arg.

Sorry for the confusion, you are right, this part is correct. I misread
the indentation.

Michal Kubecek
