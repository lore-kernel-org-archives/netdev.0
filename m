From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] staging: octeon-ethernet: trivial: Avoid OOPS if phydev
 is not set
Date: Tue, 15 Oct 2013 12:47:50 +0300
Message-ID: <20131015094750.GA11731@mwanda>
References: <1381690794.2848.11.camel@alpha.Speedport_W723_V_Typ_A_1_00_098>
 <20131013212810.GA15167@kroah.com>
 <20131014101051.GH6192@mwanda>
 <20131014183906.GA4260@blackmetal.musicnaut.iki.fi>
 <20131014191541.GA11797@mwanda>
 <20131014194937.GD4260@blackmetal.musicnaut.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: support@caviumnetworks.com, David Daney <david.daney@cavium.com>,
	Greg KH <gregkh@linuxfoundation.org>,
	driverdev-devel@linuxdriverproject.org,
	Sebastian =?iso-8859-1?Q?P=F6hn?= <sebastian.poehn@gmail.com>,
	netdev@vger.kernel.org
To: Aaro Koskinen <aaro.koskinen@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:26795 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753669Ab3JOJwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 05:52:41 -0400
Content-Disposition: inline
In-Reply-To: <20131014194937.GD4260@blackmetal.musicnaut.iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 14, 2013 at 10:49:37PM +0300, Aaro Koskinen wrote:
> On Mon, Oct 14, 2013 at 10:16:49PM +0300, Dan Carpenter wrote:
> > On Mon, Oct 14, 2013 at 09:39:06PM +0300, Aaro Koskinen wrote:
> > > It's initialized in cvm_oct_phy_setup_device():
> > > 
> > > 	priv->phydev = of_phy_connect(dev, phy_node, cvm_oct_adjust_link, 0,
> >       ^^^^^^^^^^^^                                 ^^^^^^^^^^^^^^^^^^^
> > 
> > Sorry I should have explained better.
> > 
> > We use cvm_oct_adjust_link() to initialize priv->phydev but
> > cvm_oct_adjust_link() depends on priv->phydev.  It seems like we would
> > hit the NULL dereference every time.  Weird huh?
> 
> It doesn't happen on my system (EdgeRouter Lite). I think you need to
> explain even more better. :-)
> 
> What you mean by "We use cvm_oct_adjust_link() to initialize
> priv->phydev..."? Sorry, maybe I'm just missing something really
> obvious...

Hm...  I didn't followed the state machine all the way through so I'm
not actually sure how this is called.  But it's weird that priv->phydev
is initialized on the left side of the assignment but dereferenced in
the function mentioned on the right side if the assignment.

Also this patch should not be marked as "trivial" in the subject.
"trivial" is only for spelling mistakes in comments etc.

regards,
dan carpenter
