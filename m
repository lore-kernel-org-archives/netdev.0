From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Tue, 19 Apr 2016 12:09:03 +0200
Message-ID: <1461060543.2766.20.camel@sipsolutions.net>
References: <1461015356.10638.124.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160418.205755.87909888849343438.davem@davemloft.net>
	 <20160418.214851.122286645854721047.davem@davemloft.net>
	 <20160418.235207.395468709808133833.davem@davemloft.net>
	 (sfid-20160419_055217_142593_BDCBC746)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roopa@cumulusnetworks.com, netdev@vger.kernel.org,
	jhs@mojatatu.com, tgraf@suug.ch, nicolas.dichtel@6wind.com,
	Emmanuel Grumbach <egrumbach@gmail.com>
To: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:49168 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753263AbcDSKJL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2016 06:09:11 -0400
In-Reply-To: <20160418.235207.395468709808133833.davem@davemloft.net> (sfid-20160419_055217_142593_BDCBC746)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-04-18 at 23:52 -0400, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 18 Apr 2016 21:48:51 -0400 (EDT)
>=20
> > I think the time has probably come to have a new netlink attribute
> > format that doesn't have this multi-decade old problem.
> =C2=A0...
>=20
> Scratch this whole idea, I think the padding attribute works a lot
> better and is backwards compatible with every properly written
> netlink application.

This talk about attribute flags reminded me about something else.

At netconf, we talked about how awkward it can be that one doesn't know
if an attribute was accepted by the kernel or simply ignored because
it's not supported (older kernel version).

I considered (and Emmanuel has started to cook up a patch for it)
adding a flag here meaning "reject if not parsed" (or so).

Now, I realize that with all the existing netlink commands one can't
actually rely on that (since it requires some infrastructure), but new
commands in existing families and also entirely new generic netlink
families would allow let userspace rely on such a thing.

Thoughts?

johannes
