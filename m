From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH 1/2] phylib: Support phy module autoloading
Date: Thu, 01 Apr 2010 18:03:48 +0100
Message-ID: <1270141428.3101.399.camel@macbook.infradead.org>
References: <1269998334.18090.278.camel@macbook.infradead.org>
	 <1270096441.12516.18.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, 553024@bugs.debian.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:45820 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753331Ab0DARER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 13:04:17 -0400
In-Reply-To: <1270096441.12516.18.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-04-01 at 05:34 +0100, Ben Hutchings wrote:
> On Wed, 2010-03-31 at 02:18 +0100, David Woodhouse wrote:
> > We don't use the normal hotplug mechanism because it doesn't work. It will
> > load the module some time after the device appears, but that's not good
> > enough for us -- we need the driver loaded _immediately_ because otherwise
> > the NIC driver may just abort and then the phy 'device' goes away.
> > 
> > Instead, we just issue a request_module() directly in phy_device_create().
> [...]
> 
> Thanks for doing this, David.  I had a stab at it earlier when this
> problem was reported in Debian <http://bugs.debian.org/553024>.  I
> didn't complete this because (a) I didn't understand all the details of
> adding new device table type, and (b) I tried to avoid duplicating
> information, which turns out to be rather difficult in modules with
> multiple drivers.

It shouldn't be _that_ hard.

You could contrive a macro which you use inside the driver definition
and which takes the phy_id and phy_id_mask as arguments, and has the
side-effect of setting up the MODULE_DEVICE_TABLE data.

> Since you've dealt with (a), and (b) is not really as important, I would
> just like to suggest some minor changes to your patch 1 (see below).
> Feel free to fold them in.  Your patch 2 would then need the
> substitutions s/phy_device_id/mdio_device_id/; s/TABLE(phy/TABLE(mdio/.

I'll tolerate the silly __u32 crap if I must for consistency, but
normally I prefer to write in C.

I did think about 'mdio:' for the module alias, but I decided that
'phy:' probably made more sense since these are PHY driver modules and
the number is the phy_id.

Kernel-doc is good though.

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

