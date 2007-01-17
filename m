From: Marcelo Tosatti <marcelo@kvack.org>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Wed, 17 Jan 2007 16:42:04 -0200
Message-ID: <20070117184204.GA3899@dmt>
References: <20070116185524.GA5681@dmt> <1169020333.9175.15.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcelo Tosatti <marcelo@kvack.org>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	Dan Williams <dcbw@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:38823 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932627AbXAQSpg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jan 2007 13:45:36 -0500
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1169020333.9175.15.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 17, 2007 at 07:52:13AM +0000, Johannes Berg wrote:
> On Tue, 2007-01-16 at 16:55 -0200, Marcelo Tosatti wrote:
> 
> > _Please_ review, this driver is targeted for mainline inclusion.
> > 
> > There have been almost no comments resulting from the first submission.
> 
> We had looked over the previous version a few days ago and noticed that
> the biggest part of the code is a mostly generic wireless stack that
> you're including along with the driver, essentially all the wlan_*
> files. I don't think that's going to fly.

How come is it a generic wireless stack? As Dan mentioned, the driver is
large, but the wireless stack is _inside_ the firmware.

It does not implement a wireless stack. Its simply an interface to the
firmware.

And using the Marvell provided firmware is a requirement for OLPC
machines, where the CPU will be shut down but the chip+firmware will
continue to forward packets in the mesh network (there are extreme power
saving constraints on these machines).

Quoting Dan Williams, who quoted the device documentation:

"This basic architecture is typical of a thick firmware architecture,
where the WLAN firmware handles all 802.11 MAC Management tasks."

"The host driver downloads standard 802.3 frames to the firmware to
transmit over the wireless link as 802.11 frames."

So it really looks like a fullmac chip, although it might require higher
interaction from the driver part, in comparison with IPW.

Its also important to note, regarding the size in LOC, that the driver
implements most of the firmware/chip configuration knobs, and there are
a _lot_ of them, unlike smaller in-tree drivers. (ie. the driver is
highly configurable). See the README file for a list.

> Also a bunch of minor things but I'd rather look over this version again
> before commenting on that.

Please go ahead and comment on all minor issues you see so we can fix
them.
