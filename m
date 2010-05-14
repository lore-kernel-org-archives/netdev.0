From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next-2.6 V6 PATCH 1/2] Add netlink support for virtual port management (was iovnl)
Date: Fri, 14 May 2010 09:17:28 +0200
Message-ID: <201005140917.28655.arnd@arndb.de>
References: <20100513201714.25579.53530.stgit@savbu-pc100.cisco.com> <20100513210828.GD30483@x200.localdomain> <4BEC6B19.1040808@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Chris Wright <chrisw@redhat.com>,
	Scott Feldman <scofeldm@cisco.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:50990 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757430Ab0ENHRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 03:17:48 -0400
In-Reply-To: <4BEC6B19.1040808@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 13 May 2010, Patrick McHardy wrote:
> > +enum {
> > +     VF_PORT_REQUEST_PREASSOCIATE = 0,
> > +     VF_PORT_REQUEST_PREASSOCIATE_RR,
> > +     VF_PORT_REQUEST_ASSOCIATE,
> > +     VF_PORT_REQUEST_DISASSOCIATE,
> > +};
> 
> Do multiple of these commands have to be issued in order to
> reach "associated" state? That also wouldn't fit into the
> rtnetlink design, which contains state, not commands.

In 802.1Qbg (see http://www.ieee802.org/1/files/public/docs2010/bg-joint-evb-0410v1.pdf)
they are defined both as state and as commands. I suggested
using the same definition so that we can use the exact values
when forming or receiving a TLV for the VDP protocol. We can change
freely between the first three during guest migration, but the port
(identified by the UUID) can only be in associate state on one
machine, and the switches would use that information to redirect
the data flow to the target of the migration.

The disassociate state is a bit strange in netlink because it
essentially means that the other information is now invalid,
but I'm not sure if there is a good alternative. If the switch
tells us that it is setting the link into disassociate state,
that should still be visible in netlink.

	Arnd
