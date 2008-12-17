From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: net: RFC ethtool 5-tuple filter set/get feature
Date: Wed, 17 Dec 2008 02:55:59 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.64.0812170244020.9772@ppwaskie-MOBL2.amr.corp.intel.com>
References: <Pine.WNT.4.64.0812151630570.10472@ppwaskie-MOBL2.amr.corp.intel.com>
 <20081215.225013.248487837.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Santwona.Behera@Sun.COM" <Santwona.Behera@Sun.COM>,
	"Matheos.Worku@Sun.COM" <Matheos.Worku@Sun.COM>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:58800 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750721AbYLQK4H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2008 05:56:07 -0500
In-Reply-To: <20081215.225013.248487837.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Dec 2008, David Miller wrote:

> From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
> Date: Mon, 15 Dec 2008 18:52:07 -0800 (Pacific Standard Time)
> 
> > I am looking at current methods to support adding 5-tuple filters to a 
> > network device.  3 methods I can see are 1) Creating a sysfs interface, 2) 
> > writing a custom application using netlink or some other interface, or 3) 
> > Adding support to ethtool.
> 
> I'm pretty sure ethtool is the best mechanism currently.

I'm glad.  I was targeting that, but wanted community confirmation.  :-)

> 
> > The latest ethtool bits support the rxhash callbacks, allowing different 
> > Rx hashing methods to be enabled or disabled in Sun's Neptune device.  I 
> > would like to add similar options to ethtool to support features in 
> > current versions of igb hardware, and in future ixgbe hardware.
> 
> You could extend the existing RXHASH ethtool thing, adding your
> key specifiers and some capability flags.
> 
> Actually, the Neptune folks (Santwona and Matheos CC:'d) are working
> on ethtool interfaces to load TCAM entries, which would specify the
> same things (except be a lot more flexible, multiple entries can be
> loaded into Neptune, up to 128 or 256, with all kinds of masking etc.)

Future ixgbe-supported hardware can support 128 entries to start, and then 
has another mode to support 8192 entries, plus masking on each field.  igb 
supports 8 entries today (not many Rx queues at 1G...), so it's a subset.  
So I think my needs would definately be satisfied with the work being 
proposed.

> We could represent igb/ixgbe as a TCAM with one entry and no
> masking support.  Or something like that.

If that's for a first cut, sure thing.  But ixgbe will require full 
masking support in the future.  We can take care of this when the need 
arises if it doesn't exist out of the gate.

> You can find their proposal by looking for "Interface proposal for rx
> classification using ethtool" subject in the netdev archives for
> September 2008.  I believe it was posted on the 29th.

I found the thread, and am echo'ing the same question that was posted last 
to that thread.  What's the state of the patches?  I know there was a 
target of mid-November to submit a new patchset, but I'm also sensitive 
that priorities shift day to day, let alone month to month.  I'm ready to 
work on this, and have some early code chunks if needed.  I will hold off 
on posting anything until the Sun folks have a chance to respond, since I 
don't want to cloud their efforts by posting my patches.

Cheers,
-PJ Waskiewicz
<peter.p.waskiewicz.jr@intel.com>
