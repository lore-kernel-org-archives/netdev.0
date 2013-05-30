From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH net-next v3 2/2] vxlan: allow specifying multiple default destinations
Date: Thu, 30 May 2013 14:16:26 +0300
Message-ID: <CAF1J0HP+Wu9HjEELDaXM2BMREMuKByWr_zz=PwHeNUt=EVbdvw@mail.gmail.com>
References: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>
	<1369821617-29098-3-git-send-email-mike.rapoport@ravellosystems.com>
	<20130530110948.GA10532@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog109.obsmtp.com ([74.125.245.86]:44337 "HELO
	na3sys010aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1030406Ab3E3LQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 07:16:27 -0400
Received: by mail-ob0-f176.google.com with SMTP id v19so236215obq.21
        for <netdev@vger.kernel.org>; Thu, 30 May 2013 04:16:26 -0700 (PDT)
In-Reply-To: <20130530110948.GA10532@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 30, 2013 at 12:09:48PM +0100, Thomas Graf wrote:
> Looks much better, thanks for taking the feedback. Some additional
> feedback inlined:
>
> > +   const struct vxlan_dev *vxlan)
> > +{
> > + struct vxlan_rdst *rdst;
> > + struct nlattr *nest, *rdst_nest;
> > + __be32 ip;
> > + int i;
> > +
> > + if (vxlan->remote_cnt) {
> > + nest = nla_nest_start(skb, IFLA_VXLAN_REMOTES);
> > + if (nest == NULL)
> > + goto nla_put_failure;
> > +
> > + for (rdst = vxlan->default_dst.remote_next, i = 0; rdst;
> > +     rdst = rdst->remote_next, i++) {
> > + ip = rdst->remote_ip;
> > +
> > + rdst_nest = nla_nest_start(skb, i);
>
> Attribute type '0' is reserved, please don't use it. Start with '1'.
>
> > +enum {
> > + IFLA_VXLAN_REMOTE_NEW,
> > + IFLA_VXLAN_REMOTE_DEL,
> > +};
>
> Same here, attribute type '0' is reserved.

Does it mean I have to add _UNSPEC and _MAX? And, consequently, rename
either REMOTE_{NEW,DEL} or REMOTE_ADDR and friends to avoid redefinition
of _MAX attribute?

--
Sincerely yours,
Mike.
