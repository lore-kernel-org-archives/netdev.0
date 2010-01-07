From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] e1000: enhance frame fragment detection
Date: Wed, 6 Jan 2010 19:56:29 -0500
Message-ID: <20100107005629.GA2020@localhost.localdomain>
References: <20091228201005.GC18422@hmsreliant.think-freely.org>
 <alpine.WNT.2.00.1001051341110.4056@jbrandeb-desk1.amr.corp.intel.com>
 <alpine.WNT.2.00.1001061525050.4056@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55902 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752246Ab0AGA4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 19:56:35 -0500
Content-Disposition: inline
In-Reply-To: <alpine.WNT.2.00.1001061525050.4056@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 06, 2010 at 03:27:42PM -0800, Brandeburg, Jesse wrote:
> a counter patch, without atomic ops, since we are protected by napi when 
> modifying this variable.
> 
> Originally From: Neil Horman <nhorman@tuxdriver.com>
> Modified by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> <original message>
> Hey all-
> 	A security discussion was recently given:
> http://events.ccc.de/congress/2009/Fahrplan//events/3596.en.html
> And a patch that I submitted awhile back was brought up.  Apparently some of
> their testing revealed that they were able to force a buffer fragment in e1000
> in which the trailing fragment was greater than 4 bytes.  As a result the
> fragment check I introduced failed to detect the fragement and a partial
> invalid frame was passed up into the network stack.  I've written this patch
> to correct it.  I'm in the process of testing it now, but it makes good
> logical sense to me.  Effectively it maintains a per-adapter state variable
> which detects a non-EOP frame, and discards it and subsequent non-EOP frames
> leading up to _and_ _including_ the next positive-EOP frame (as it is by
> definition the last fragment).  This should prevent any and all partial frames
> from entering the network stack from e1000.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Seems like a fine alternative to me.  Thanks!
Acked-by: Neil Horman <nhorman@tuxdriver.com>

