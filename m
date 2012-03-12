From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 2.6.32.y] netxen: support for GbE port settings
Date: Mon, 12 Mar 2012 10:09:50 +0100
Message-ID: <20120312090950.GC11569@1wt.eu>
References: <1300172175-16853-1-git-send-email-amit.salecha@qlogic.com> <20120312043539.GA15903@burratino>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	stable@vger.kernel.org, Sony Chacko <sony.chacko@qlogic.com>,
	Ana Guerrero <ana@debian.org>,
	Michael Mastrogiacomo <mmastrogiacomo@ultralogistics.com>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: Jonathan Nieder <jrnieder@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:63170 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753918Ab2CLJU1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2012 05:20:27 -0400
Content-Disposition: inline
In-Reply-To: <20120312043539.GA15903@burratino>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jonathan,

On Sun, Mar 11, 2012 at 11:35:39PM -0500, Jonathan Nieder wrote:
> From: Sony Chacko <sony.chacko@qlogic.com>
> Date: Tue, 15 Mar 2011 14:54:55 -0700
> 
> commit bfd823bd74333615783d8108889814c6d82f2ab0 upstream.
> 
> o Enable setting speed and auto negotiation parameters for GbE ports.
> o Hardware do not support half duplex setting currently.
> 
> David Miller:
> 	Amit please update your patch to silently reject link setting
> 	attempts that are unsupported by the device.
> 
> [jn: backported for 2.6.32.y by Ana Guerrero]
> 
> Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> Tested-by: Ana Guerrero <ana@debian.org> # HP NC375i
> Signed-off-by: Jonathan Nieder <jrnieder@gmail.com>
> ---
> Hi Dave,
> 
> Michael Mastrogiacomo reports[1]:
> 
> > The HP NC375i network card on an HP ML370 G6 server with Debian
> > squeeze OS installed as problems.
> >
> > The server is connected to a switch that does only 100/full and it
> > fails to autonegotiate correctly during reboot.  A network
> > connection can be used if the switch side gets locked to 100 half
> > however which seems to be what the HP card assumes if negotiaton
> > fails.  The HP card seems to assume a speed of 1000 which is
> > incorrect.  It should learn a speed of 100 advertised by the switch
> > which it fails to do.  
> >
> > Certain ethtool and miitool functions do not seem to work such as
> > ethtool -s (you can't set any parameters at all).   ethtool -t also
> > fails.  
> 
> Ana Guerrero wrote:
> 
> > Yes, it is a driver bug. We hit in this same problem because the
> > switches are not configured to allow auto-negociated GbE.
> > Eg with ethtool:
> > 
> > # ethtool -s eth0 autoneg off
> >     Cannot set new settings: Input/output error not setting autoneg
> > #
> > 
> > The patch at
> > [...]h=bfd823bd74333615783d8108889814c6d82f2ab0
> >
> > fixes this problem. I am attaching it already updated to work on top
> > of 2.6.32-41.
> >
> > The patch has been tested successfully with a HP NC3751 card like
> > the reporter.
> 
> Therefore I would like to see this patch in a future 2.6.32.y kernel,
> so everyone using that as a baseline can benefit from the fix.  The
> patch hit mainline in the 2.6.39 merge window.
> 
> What is the right way to submit networking patches for the 2.6.32.y
> tree?  Should I send them to you or directly to Willy, are your
> requirements for them the same as the usual stable_kernel_rules.txt or
> other ones, and is [2] the right place to find a preview of patches
> destined for longterm trees or do they go somewhere else?

In general, valid driver fixes should be merged as they fix issues
affecting users. One very important requirement for merging such a
fix is that it is already present in more recent stable releases :
when users upgrade from 2.6.32 to 3.0, we don't want them to get
the bug again.

If this requirement is satisfied and David is not opposed to merging
the patch, then we can include it (even in this release, considering
the authors and reviewers are already CC'd).

Regards,
Willy
