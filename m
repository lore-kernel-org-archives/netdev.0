From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: ethtool: missing implementation of n_priv_flags
Date: Thu, 28 Oct 2010 14:10:30 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.1010281405001.11080@jbrandeb-desk1.amr.corp.intel.com>
References: <F169D4F5E1F1974DBFAFABF47F60C10AA5E60671@orsmsx507.amr.corp.intel.com> <20101028210024.GK15074@solarflare.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "jgarzik@redhat.com" <jgarzik@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:40659 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753217Ab0J1VKc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Oct 2010 17:10:32 -0400
In-Reply-To: <20101028210024.GK15074@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Oct 2010, Ben Hutchings wrote:
> Brandeburg, Jesse wrote:
> > Was just looking at implementing the driver private flags to add a new feature to 
> > a driver.
> > 
> > It appears that nothing in the core ethtool.c ever accesses or prints n_priv_flags, 
> > even if a driver assigns it (which none in the kernel currently do)
> [...]
> 
> You mean net/core/ethtool.c?  Or the ethtool utility?

The ethtool utility (the app that would print the 1-1 match between bits 
and strings)
 
> If you set it in your get_drvinfo() operation then it will be copied out.
> As for the ethtool utility, I've implemented some generic flag parsing and
> printing functionality so it shouldn't be too hard to use that for private
> flags.

Right, I see the code where it gets copied into drvinfo in the kernel but 
nothing ever prints it on the userspace side.

We'll take a shot at an implementation in the ethtool proper and post it 
(hopefully soon).  I imagine it will just be printed when one runs the 
command 
# ethtool ethX

and the set side will probably be implemented as part of -s

# ethtool -s ethX pflag [0-0xFFFFFFFF]

