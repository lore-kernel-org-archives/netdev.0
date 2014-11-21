From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 3/4] igb: enable internal PPS for the i210.
Date: Fri, 21 Nov 2014 06:49:42 +0100
Message-ID: <20141121054942.GA4078@localhost.localdomain>
References: <cover.1416265321.git.richardcochran@gmail.com>
 <e5b4ef7c56119e2d86e42f5680b1b82c9ec1a38e.1416265321.git.richardcochran@gmail.com>
 <20141119063724.GB4109@localhost.localdomain>
 <1416425553.15933.32.camel@jekeller-desk1.amr.corp.intel.com>
 <20141119202604.GA22213@localhost.localdomain>
 <1416431178.15933.38.camel@jekeller-desk1.amr.corp.intel.com>
 <20141120091804.GA4587@localhost.localdomain>
 <1416518906.21611.8.camel@jekeller-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:44409 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733AbaKUFts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 00:49:48 -0500
Received: by mail-wi0-f174.google.com with SMTP id h11so10916398wiw.13
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2014 21:49:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1416518906.21611.8.camel@jekeller-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 20, 2014 at 09:28:26PM +0000, Keller, Jacob E wrote:
> Here is the problem. In igb_reset, we call e1000_reset_hw() which will
> eventually perform a hardware MAC reset. Yes maybe we shouldn't be
> calling igb_reset everywhere.. I cannot answer that, however...

It is a typical device driver "code smell". The developer thinks, 
"Hm, something isn't working in this function. I know - lets reset the
device. That _always_ works."

> Some of the ethtool settings maybe could avoid resets, but I am not
> certain during exactly which path they end up calling resets.

Jup. Surely changing the MTU is no reason to reset the PTP clock. But
as you said, fixing the reset stuff is a huge amount of work. Instead
of trying to do that, I'll just go with the flow and reset the
auxiliary functions, too.

Thanks,
Richard
