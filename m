From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [RFC] vxlan: convert remote list to list_rcu
Date: Tue, 4 Jun 2013 20:22:02 +0300
Message-ID: <CAF1J0HOYRe-HiiEFFrB-Nk-V-UOfu25KVcyn02cA-t4S675-9Q@mail.gmail.com>
References: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>
	<1369821617-29098-3-git-send-email-mike.rapoport@ravellosystems.com>
	<20130530110948.GA10532@casper.infradead.org>
	<CAF1J0HP+Wu9HjEELDaXM2BMREMuKByWr_zz=PwHeNUt=EVbdvw@mail.gmail.com>
	<20130530113739.GB10532@casper.infradead.org>
	<20130531091740.70b3e077@nehalam.linuxnetplumber.net>
	<20130602102942.GA21706@zed>
	<20130603112616.3ad018e2@nehalam.linuxnetplumber.net>
	<OFE7269995.C8314337-ON85257B7F.006B4FC1-85257B7F.006F87F8@us.ibm.com>
	<CAF1J0HNDrqAfWSkdsF7UW=EqJ5yv8hN-uGZi+SRa1F2nYMZWxw@mail.gmail.com>
	<20130604090031.1283b96f@nehalam.linuxnetplumber.net>
	<OFF0160A91.9C9E7EC3-ON85257B80.00594BB9-85257B80.005A8D71@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog112.obsmtp.com ([74.125.245.92]:53472 "HELO
	na3sys010aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752604Ab3FDRWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 13:22:04 -0400
Received: by mail-ob0-f182.google.com with SMTP id va7so873882obc.13
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 10:22:03 -0700 (PDT)
In-Reply-To: <OFF0160A91.9C9E7EC3-ON85257B80.00594BB9-85257B80.005A8D71@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 04, 2013 at 12:29:05PM -0400, David Stevens wrote:
> Stephen Hemminger <stephen@networkplumber.org> wrote on 06/04/2013
> 12:00:31 PM:
>
> > I am still not 100% convinced of the use case of providing multiple
> > destinations.
> > It seems like either a solution for migrating guests, a way to do
> > SPAN, or a weird
> > form of multicast.
>
> The use is, as you would say it, a weird form of multicast. It
> is to allow forwarding MAC multicasts without relying on the
> underlying network having multicast routers in the same domain.

For instance, public clouds do not allow multicasts, and vxlan with
multiple destinations would be a neat SDN solution there.

> > Wouldn't it be better to use something like TC actions for these
> > special cases and
> > handle it at the IP layer rather than having to add so much
> > complexity into the
> > VXLAN driver itself.
>
> This isn't a "special case" for DOVE -- it is the mechanism
> for doing MAC multicasts. I don't agree that the code is
> complex -- it simply replaces what was a vxlan_rdst with a
> list of vxlan_rdsts. And, no, I don't believe it can be
> done with equivalent performance using external mechanisms.
>
> Didn't we have this discussion when the patch went in?
>
>                                                         +-DLS
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
