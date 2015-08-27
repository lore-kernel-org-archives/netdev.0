From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 0/2] Add new switchdev device class
Date: Thu, 27 Aug 2015 11:06:03 +0200
Message-ID: <20150827090603.GC8094@lunn.ch>
References: <1440659806-56582-1-git-send-email-sfeldma@gmail.com>
 <20150827074525.GA8094@lunn.ch>
 <CAE4R7bD0Ka0187Qq=+6cZL7UqgnxJASKL_6AmaC2z_jiF5Jp1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	=?iso-8859-1?B?Smk/P+0gUO1ya28=?= <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40727 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751444AbbH0JNe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2015 05:13:34 -0400
Content-Disposition: inline
In-Reply-To: <CAE4R7bD0Ka0187Qq=+6cZL7UqgnxJASKL_6AmaC2z_jiF5Jp1w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 27, 2015 at 01:42:24AM -0700, Scott Feldman wrote:
> On Thu, Aug 27, 2015 at 12:45 AM, Andrew Lunn <andrew@lunn.ch> wrote:
> >> I don't know about how this overlaps with DSA platform_class.  Florian?
> >
> > There is some overlap with DSA, but the current DSA model, with
> > respect to probing, is broken. So this might be interesting as a way
> > towards fix that.
> >
> > One thing to keep in mind is the D in DSA. You talk about switch,
> > singular. DSA has a number of switches in a cluster. We currently
> > export a single switchdev interface for the cluster, but there are
> > some properties which are per switch, e.g. temperature, eeprom
> > contents, statistics, power management etc.
> 
> Export a single 'switchdev' or 'netdev' for the cluster?  I hope that
> was a typo.

I probably expressed that badly. The hardware i have on my desk has
three Marvell switches in a chain, with one end of the chain connected
to a host Ethernet interface.

>From the switchdev ops level, you don't see anything of this
chain. But some of the operations do need to be aware of this chain,
for example vlans which span multiple chips in this chain.

> With switchdev device class, you'd instantiate one per
> phy switch, and have per-switch props (temp, eeprom, etc) thru each
> switchdev instance.

O.K. This is fine, but we need people to understand that a switchdev
device class represents some middle layer in the hierarchy, not the
top layer. Otherwise false assumptions might be made.

    Andrew
