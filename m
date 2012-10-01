From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] gre: conform to RFC6040 ECN progogation
Date: Mon, 1 Oct 2012 14:21:35 -0700
Message-ID: <20121001142135.6580b3eb@nehalam.linuxnetplumber.net>
References: <20120924184304.727711327@vyatta.com>
	<20120924185050.162920909@vyatta.com>
	<20120924205822.GI26494@x200.localdomain>
	<20120924141133.3c97e9de@nehalam.linuxnetplumber.net>
	<20120924212226.GJ26494@x200.localdomain>
	<20120924144457.0c76bce2@nehalam.linuxnetplumber.net>
	<1349106919.2577.9.camel@bwh-desktop.uk.solarflarecom.com>
	<20121001085606.6f828f7d@nehalam.linuxnetplumber.net>
	<1349110181.2577.16.camel@bwh-desktop.uk.solarflarecom.com>
	<1349111627.12401.714.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Chris Wright <chrisw@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58554 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751492Ab2JAVWK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2012 17:22:10 -0400
In-Reply-To: <1349111627.12401.714.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 01 Oct 2012 19:13:47 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Mon, 2012-10-01 at 17:49 +0100, Ben Hutchings wrote:
> 
> > I don't think rx_dropped is appropriate for counting invalid packets,
> > but maybe actual practice is already different.
> > 
> > As for whether packets counted in rx_dropped should also be counted in
> > rx_packets/rx_bytes, I really don't know.  The current comments on
> > rtnl_link_stats (inherited from net_device_stats) are totally inadequate
> > as a specification.
> 
> rx_dropped is used by core network stack, not the devices themselves.
> 
> So a packet is first accounted in rx_bytes/rx_packets by the driver,
> and if net/core/dev.c drops it, rx_dropped is incremented as well.

The tunnel drivers are consistent in putting any dropped packet because
of protocol problem into a rx_XXX_error value and incrementing rx_errors.

I just made it treat ECN bit breakage like all the other protocol errors.
