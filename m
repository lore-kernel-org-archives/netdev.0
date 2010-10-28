From: Jeff Garzik <jgarzik@redhat.com>
Subject: Re: ethtool: missing implementation of n_priv_flags
Date: Thu, 28 Oct 2010 17:59:21 -0400
Message-ID: <20101028215921.GC9421@shell.devel.redhat.com>
References: <F169D4F5E1F1974DBFAFABF47F60C10AA5E60671@orsmsx507.amr.corp.intel.com> <20101028210024.GK15074@solarflare.com> <alpine.WNT.2.00.1010281405001.11080@jbrandeb-desk1.amr.corp.intel.com> <20101028215417.GL15074@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32773 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758818Ab0J1V7Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Oct 2010 17:59:24 -0400
Content-Disposition: inline
In-Reply-To: <20101028215417.GL15074@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 28, 2010 at 10:54:18PM +0100, Ben Hutchings wrote:
> Brandeburg, Jesse wrote:
> [...]
> > We'll take a shot at an implementation in the ethtool proper and post it 
> > (hopefully soon).  I imagine it will just be printed when one runs the 
> > command 
> > # ethtool ethX
> > 
> > and the set side will probably be implemented as part of -s
> > 
> > # ethtool -s ethX pflag [0-0xFFFFFFFF]
> 
> This is crap.  Use ETHTOOL_GSTRINGS with string_set = ETH_SS_PRIV_FLAGS
> to get the flag names, then convert that array into an array of struct
> cmdline_info and parse the flags by name.

Indeed.  It was intended to be a flexible interface where a driver can
easily pass arbitrary text-named flags to the user for setting/clearing.

If e1000e has a special Intel-specific feature that makes the NIC
process packets more rapidly, you could select the string "go_faster" in
the ethtool private flags interface.  The ethtool utility reads the
strings, which determine the flags exported for that network interface.

	Jeff



