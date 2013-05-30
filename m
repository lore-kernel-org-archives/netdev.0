From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH iproute2] vxlan: allow specifying multiple default
 destinations
Date: Thu, 30 May 2013 15:46:52 +0300
Message-ID: <20130530124652.GA29547@zed.ravello.local>
References: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>
 <1369821617-29098-4-git-send-email-mike.rapoport@ravellosystems.com>
 <ko4kcr$h8j$1@ger.gmane.org>
 <CAF1J0HPDAkhAybQt-tOFLLTLzaXiWy_TSbFF2FT3PMaXbnxJuw@mail.gmail.com>
 <20130529155625.2ee5f6bb@nehalam.linuxnetplumber.net>
 <CAF1J0HNiBED=BLHqPPk8w2=DDvSWdZwMPvtag6rpPhxnboT4GA@mail.gmail.com>
 <20130530114424.GC10532@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog113.obsmtp.com ([74.125.245.94]:57384 "HELO
	na3sys010aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752464Ab3E3Mq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 08:46:59 -0400
Received: by mail-ea0-f173.google.com with SMTP id n15so257217ead.32
        for <netdev@vger.kernel.org>; Thu, 30 May 2013 05:46:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130530114424.GC10532@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 30, 2013 at 12:44:24PM +0100, Thomas Graf wrote:
> On 05/30/13 at 11:42am, Mike Rapoport wrote:
> > On Thu, May 30, 2013 at 1:56 AM, Stephen Hemminger
> > <stephen@networkplumber.org> wrote:
> > > On Wed, 29 May 2013 13:52:55 +0300
> > > Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:
> > >> Frankly, I had a long hesitation about the userspace implementation.
> > >> From one side it seems very logical to use ip/iplink_vxlan for vxlan
> > >> device manipulations. Moreover, since the remotes are used pretty much
> > >> the same way as the group address, adding the remotes management to
> > >> ip/iplink_vxlan makes a lot of sense. Besides, creation of stand alone
> > >> tool for remote list manipulation in vxlan seemed to me little bit far
> > >> fetched.
> > >>
> > >> On the other hand, I quite agree with you that
> > >> ip link add vxlan0 ... dstadd 192.168.1.1
> > >> or
> > >> ip link set vxlan0 ... dstdel 192.168.1.1
> > >> looks weird at least.
> > >
> > > Don't like add/delete semantics here either.
> > > Maybe replace or modify,
> > 
> > I think that replace or modify do not express the actual operation
> > meaning. My intention with dstadd was "add remote host X to
> > pseudo-multicast group". Replace/modify maybe nice to have features to
> > avoid doing delete+ add.
> 
> The alternative would be to require iproute2 to always provide the
> full list of remote addresses like we do we route nexthops.
> 
> I do like the add/del though and don't see a problem with requiring
> an ''ip link set [..] dstadd/dstdel''

I'm feeling Ok about "ip link set [..] dstadd/dstdel". What does bother
me is that you can't have different parameters for "ip link add" and "ip
link set" for vxlan (and other iplink) utility. So, one can use
ip link add [..] dstdel
which does not make sense...

> > > or has this grown enough that having its own
> > > command line tool "vxlan ..." makes sense?
> > 
> > Say, misc/vxlan that will handle remote destinations management? Or
> > should it take care of some vxlan parameters currently implemented in
> > ip/iplink_vxlan and bridge/fdb?
> 
> What do we gain from a separate tool?

--
Sincerely yours,
Mike.
