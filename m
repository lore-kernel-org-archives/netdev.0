From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [net v6 1/8] i40e: main driver core
Date: Sun, 8 Sep 2013 01:01:36 +0200
Message-ID: <20130907230136.GA24530@electric-eye.fr.zoreil.com>
References: <1378510875-10704-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1378510875-10704-2-git-send-email-jeffrey.t.kirsher@intel.com>
 <522ACB54.2050706@redhat.com>
 <1378581636.2509.12.camel@jbrandeb-mobl.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51536 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780Ab3IGXB5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Sep 2013 19:01:57 -0400
Content-Disposition: inline
In-Reply-To: <1378581636.2509.12.camel@jbrandeb-mobl.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brandeburg, Jesse <jesse.brandeburg@intel.com> :
> On Sat, 2013-09-07 at 08:44 +0200, Daniel Borkmann wrote:
> 
> > Nitpicking ... at some point in time i40e_status should be removed plus
> > I40E_ERR_PARAM, I40E_SUCCESS, I40E_ERR_NO_MEMORY and the like, as we have
> > int and -EINVAL, 0, -ENOMEM for that. ;-)
> 
> First, thanks Daniel for taking the time to review.
> 
> Those are a result of our files that are shared across OSes, as not all
> OSes have -ENOMEM etc, we also have a lot of status codes the kernel
> doesn't have.  That said, when there is a 1-1 relationship the
> replacements should be made.  

It should always be made. You have kept ignoring it since june (see
Ben Hutchings's comment on 2013/06/19).

Where did you see that rules changed and the linux kernel should care
about OS shared code ?

- the patchkit does not include a Makefile to compile from patch #1
- it would not compile since patch #1 depends on stuff that appears
  later (see i40e_hw or i40e_lump_tracking for instance).
- some of the I40E_ERR_PARAM error can't happen or are assert() in
  disguise that could / should instead BUG(). There is no reason to
  confuse these with runtime failures, especially as code gets really
  tested on hardware.

I could understand it from some newly introduced company but it's
a bit deceptive from Intel. :o/

-- 
Ueimor
