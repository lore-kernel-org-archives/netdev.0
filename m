From: Bill Fink <billfink@mindspring.com>
Subject: Re: inconsistency of ethtool feature names for get vs. set
Date: Mon, 6 Jan 2014 23:58:58 -0500
Message-ID: <20140106235858.5ce80054.billfink@mindspring.com>
References: <52C535B9.7080208@mellanox.com>
	<1388675034.1607.9.camel@bwh-desktop.uk.level5networks.com>
	<1388688114.9947.30.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>, netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-junco.atl.sa.earthlink.net ([209.86.89.63]:45846 "EHLO
	elasmtp-junco.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751581AbaAGFFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 00:05:20 -0500
In-Reply-To: <1388688114.9947.30.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2 Jan 2014, Ben Hutchings wrote:

> On Thu, 2014-01-02 at 15:03 +0000, Ben Hutchings wrote:
> > On Thu, 2014-01-02 at 11:47 +0200, Or Gerlitz wrote:
> [...]
> > > $ ethtool -k eth1  | grep generic-receive-offload
> > > generic-receive-offload: on
> > > 
> > > $ ethtool -K eth1  generic-receive-offload off
> > > ethtool: bad command line argument(s)
> > > For more information run ethtool -h
> > > 
> > > --> looking in the sources and realizing I need to use "rx-gro"
> > 
> > Or 'gro'.  All the old feature names that can be used with the -K option
> > are listed in the manual page.  All the new feature names are consistent
> > between -k/-K.
> 
> By 'new feature names' I mean names for features that weren't previously
> exposed through ethtool.
> 
> [...]
> > > Basically, this can be resolved by fairly simple patch, but I wasn't 
> > > sure if you want it in user space, in the kernel or both...
> > 
> > How do you intend to resolve this, given the compatibility requirement
> > that the old names must still be reported by -k and accepted by -K?
> 
> Just to be clear, I do see that there's a problem here but the fix may
> have to be mostly or entirely in documentation rather than code.

Wouldn't one simple option be to allow the long form like
generic-receive-offload for setting in addition to the existing
shortcuts rx-gro and gro?  That way a user doing "ethtool -k"
could use the name provided to do a set via "ethtool -K" without
needing to consult a man page (or "ethtool -h"), while still
allowing more knowledgeable users to use the shortcut names.

					-Bill
