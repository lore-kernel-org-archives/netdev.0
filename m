From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [RFC] vxlan: convert remote list to list_rcu
Date: Tue, 4 Jun 2013 12:29:05 -0400
Message-ID: <OFF0160A91.9C9E7EC3-ON85257B80.00594BB9-85257B80.005A8D71@us.ibm.com>
References: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>	<1369821617-29098-3-git-send-email-mike.rapoport@ravellosystems.com>
	<20130530110948.GA10532@casper.infradead.org>	<CAF1J0HP+Wu9HjEELDaXM2BMREMuKByWr_zz=PwHeNUt=EVbdvw@mail.gmail.com>
	<20130530113739.GB10532@casper.infradead.org>	<20130531091740.70b3e077@nehalam.linuxnetplumber.net>
	<20130602102942.GA21706@zed>	<20130603112616.3ad018e2@nehalam.linuxnetplumber.net>
	<OFE7269995.C8314337-ON85257B7F.006B4FC1-85257B7F.006F87F8@us.ibm.com>	<CAF1J0HNDrqAfWSkdsF7UW=EqJ5yv8hN-uGZi+SRa1F2nYMZWxw@mail.gmail.com> <20130604090031.1283b96f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Mike Rapoport <mike.rapoport@ravellosystems.com>,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:36356 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755335Ab3FDQ33 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jun 2013 12:29:29 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Tue, 4 Jun 2013 12:29:27 -0400
In-Reply-To: <20130604090031.1283b96f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> wrote on 06/04/2013 
12:00:31 PM:

> I am still not 100% convinced of the use case of providing multiple 
> destinations.
> It seems like either a solution for migrating guests, a way to do 
> SPAN, or a weird
> form of multicast.

The use is, as you would say it, a weird form of multicast. It
is to allow forwarding MAC multicasts without relying on the
underlying network having multicast routers in the same domain.
 
> Wouldn't it be better to use something like TC actions for these 
> special cases and
> handle it at the IP layer rather than having to add so much 
> complexity into the
> VXLAN driver itself.

This isn't a "special case" for DOVE -- it is the mechanism
for doing MAC multicasts. I don't agree that the code is
complex -- it simply replaces what was a vxlan_rdst with a
list of vxlan_rdsts. And, no, I don't believe it can be
done with equivalent performance using external mechanisms.

Didn't we have this discussion when the patch went in?

                                                        +-DLS
