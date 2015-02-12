From: Chris Vine <chris@cvine.freeserve.co.uk>
Subject: Re: xt_recent broken in kernel 3.19.0 + PATCH
Date: Thu, 12 Feb 2015 10:54:17 +0000
Message-ID: <20150212105417.0379fed8@bother.homenet>
References: <20150211092834.65f8ae80@bother.homenet>
	<20150211183121.6688aec8@bother.homenet>
	<CAM_iQpVmxw_XfzP7yaPWbhu8UBujebm1vjumgPPH1TUdHgs0rA@mail.gmail.com>
	<20150212083533.GC22887@breakpoint.cc>
	<20150212102616.786da70c@bother.homenet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150212102616.786da70c@bother.homenet>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 12 Feb 2015 10:26:16 +0000
Chris Vine <chris@cvine.freeserve.co.uk> wrote:
> On Thu, 12 Feb 2015 09:35:33 +0100
> Florian Westphal <fw@strlen.de> wrote:
> > Cong Wang <xiyou.wangcong@gmail.com> wrote:
> > > (Cc'ing netdev and netfilter-devel lists)
> > 
> > Thanks for forwarding.
> > 
> > > > Chris Vine <chris@cvine.freeserve.co.uk> wrote:
> > > >>   iptables -D SSH_CHAIN -m conntrack --ctstate NEW \
> > > >>     -m recent --update --seconds $SSH_LOGIN_PERIOD --hitcount
> > > >> $SSH_TRIES -j DROP
> > > > --- linux-3.19.0/net/netfilter/xt_recent.c~     2015-02-10
> > > > 09:18:44.657376355 +0000 +++
> > > > linux-3.19.0/net/netfilter/xt_recent.c      2015-02-11
> > > > 17:58:33.311608835 +0000 @@ -378,7 +378,7 @@
> > > > mutex_lock(&recent_mutex); t = recent_table_lookup(recent_net,
> > > > info->name); if (t != NULL) {
> > > > -               if (info->hit_count > t->nstamps_max_mask) {
> > > > +               if (info->hit_count > t->nstamps_max_mask + 1) {
> > 
> > Looks good. Chris, could you formally submit this patch to
> > netfilter-devel@vger.kernel.org?
> > 
> > Thanks!
> 
> Done.

On further testing I see that that patch only solves the problem if
SSH_TRIES is set to a power of two boundary.  You still get an error
loading the rule if it is anything else.  I think there is something
wrong with the nstamp_mask heuristic which is used here.

Chris
