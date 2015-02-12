From: Florian Westphal <fw@strlen.de>
Subject: Re: xt_recent broken in kernel 3.19.0 + PATCH
Date: Thu, 12 Feb 2015 09:35:33 +0100
Message-ID: <20150212083533.GC22887@breakpoint.cc>
References: <20150211092834.65f8ae80@bother.homenet>
 <20150211183121.6688aec8@bother.homenet>
 <CAM_iQpVmxw_XfzP7yaPWbhu8UBujebm1vjumgPPH1TUdHgs0rA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Vine <chris@cvine.freeserve.co.uk>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAM_iQpVmxw_XfzP7yaPWbhu8UBujebm1vjumgPPH1TUdHgs0rA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cong Wang <xiyou.wangcong@gmail.com> wrote:
> (Cc'ing netdev and netfilter-devel lists)

Thanks for forwarding.

> > Chris Vine <chris@cvine.freeserve.co.uk> wrote:
> >>   iptables -D SSH_CHAIN -m conntrack --ctstate NEW \
> >>     -m recent --update --seconds $SSH_LOGIN_PERIOD --hitcount
> >> $SSH_TRIES -j DROP
> > --- linux-3.19.0/net/netfilter/xt_recent.c~     2015-02-10 09:18:44.657376355 +0000
> > +++ linux-3.19.0/net/netfilter/xt_recent.c      2015-02-11 17:58:33.311608835 +0000
> > @@ -378,7 +378,7 @@
> >         mutex_lock(&recent_mutex);
> >         t = recent_table_lookup(recent_net, info->name);
> >         if (t != NULL) {
> > -               if (info->hit_count > t->nstamps_max_mask) {
> > +               if (info->hit_count > t->nstamps_max_mask + 1) {

Looks good. Chris, could you formally submit this patch to
netfilter-devel@vger.kernel.org?

Thanks!
