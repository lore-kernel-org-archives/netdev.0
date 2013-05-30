From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v3 2/2] vxlan: allow specifying multiple default
 destinations
Date: Thu, 30 May 2013 12:37:39 +0100
Message-ID: <20130530113739.GB10532@casper.infradead.org>
References: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>
 <1369821617-29098-3-git-send-email-mike.rapoport@ravellosystems.com>
 <20130530110948.GA10532@casper.infradead.org>
 <CAF1J0HP+Wu9HjEELDaXM2BMREMuKByWr_zz=PwHeNUt=EVbdvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:54049 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751930Ab3E3Lhl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 07:37:41 -0400
Content-Disposition: inline
In-Reply-To: <CAF1J0HP+Wu9HjEELDaXM2BMREMuKByWr_zz=PwHeNUt=EVbdvw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/30/13 at 02:16pm, Mike Rapoport wrote:
> On Thu, May 30, 2013 at 12:09:48PM +0100, Thomas Graf wrote:
> > Looks much better, thanks for taking the feedback. Some additional
> > feedback inlined:
> >
> > > +   const struct vxlan_dev *vxlan)
> > > +{
> > > + struct vxlan_rdst *rdst;
> > > + struct nlattr *nest, *rdst_nest;
> > > + __be32 ip;
> > > + int i;
> > > +
> > > + if (vxlan->remote_cnt) {
> > > + nest = nla_nest_start(skb, IFLA_VXLAN_REMOTES);
> > > + if (nest == NULL)
> > > + goto nla_put_failure;
> > > +
> > > + for (rdst = vxlan->default_dst.remote_next, i = 0; rdst;
> > > +     rdst = rdst->remote_next, i++) {
> > > + ip = rdst->remote_ip;
> > > +
> > > + rdst_nest = nla_nest_start(skb, i);
> >
> > Attribute type '0' is reserved, please don't use it. Start with '1'.
> >
> > > +enum {
> > > + IFLA_VXLAN_REMOTE_NEW,
> > > + IFLA_VXLAN_REMOTE_DEL,
> > > +};
> >
> > Same here, attribute type '0' is reserved.
> 
> Does it mean I have to add _UNSPEC and _MAX? And, consequently, rename
> either REMOTE_{NEW,DEL} or REMOTE_ADDR and friends to avoid redefinition
> of _MAX attribute?

I think this is good enough:

enum {
	IFLA_VXLAN_REMOTE_NEW = 1,
	IFLA_VXLAN_REMOTE_DEL,
};
