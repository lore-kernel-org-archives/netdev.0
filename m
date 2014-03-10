From: "christoph.paasch@uclouvain.be" <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH net] igb: Unset IGB_FLAG_HAS_MSIX-flag when falling back
 to msi-only
Date: Mon, 10 Mar 2014 19:50:09 +0100
Message-ID: <20140310185009.GB8001@cpaasch-mac>
References: <1392766595-14454-1-git-send-email-christoph.paasch@uclouvain.be>
 <309B89C4C689E141A5FF6A0C5FB2118B73157E74@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Brown, Aaron F" <aaron.f.brown@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:59485 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752947AbaCJSuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 14:50:14 -0400
Content-Disposition: inline
In-Reply-To: <309B89C4C689E141A5FF6A0C5FB2118B73157E74@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Aaron,

On 19/02/14 - 00:05:30, Brown, Aaron F wrote:
> On Wed, 2014-02-19 at 00:36 +0100, Christoph Paasch wrote:
> > rior to cd14ef54d25 (igb: Change to use statically allocated array for
> > MSIx entries), having msix_entries different from NULL was an
> > indicator
> > that MSIX is enabled.
> > In igb_set_interrupt_capabiliy we may fall back to MSI-only. Prior to
> > the above patch msix_entries was set to NULL by
> > igb_reset_interrupt_capability.
> > 
> > However, now we are checking the flag for IGB_FLAG_HAS_MSIX and so the
> > stack gets completly confused:
> > 
> > [   42.659791] ------------[ cut here ]------------
> > <snip>
> 
> > [   47.892146] handlers:
> > [   47.919301] [<ffffffff812fbd7d>] igb_intr
> > 
> > So, this patch unsets the flag to indicate that we are not using MSIX.
> > This patch does exactly this: Unsetting the flag when falling back to
> > MSI.
> > 
> > Fixes: cd14ef54d25b (igb: Change to use statically allocated array for
> > MSIx entries)
> > Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
> > Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> > ---
> >  drivers/net/ethernet/intel/igb/igb_main.c | 1 +
> >  1 file changed, 1 insertion(+) 
> 
> Thanks Christoph, I have added this to our Jeff's internal queue as
> well.

are the patches in Jeff's queue?
Because, in his last pull request they were not part of it.

I think these patches should make it into 3.14, because my machines are not
booting because of these issues.


Cheers,
Christoph
