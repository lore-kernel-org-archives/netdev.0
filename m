From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 38/40] ixgbe: Update feature flags so that LRO and
 Ntuple are restricted
Date: Tue, 07 Jun 2011 14:15:59 +0100
Message-ID: <1307452559.2908.15.camel@bwh-desktop>
References: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1307449995-9458-39-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:38556 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752953Ab1FGNQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2011 09:16:02 -0400
In-Reply-To: <1307449995-9458-39-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-06-07 at 05:33 -0700, Jeff Kirsher wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change makes it so that LRO and Ntuple flags are correctly restricted
> to only devices that support those features.  Currently we weren't
> enforcing any of those restrictions and as such it was possible to do
> things such as enable LRO without it actually being supported on the
> hardware.
> 
> This change also makes a slight modification to the code that assumes the
> ETH_FLAG_RXVLAN is the same as the netdev flag. I corrected it by just adding
> a !! to cast the result of the flag & to a bool in order to guarantee the two
> checks are compared as boolean values.
[...]

You could BUILD_BUG_ON(ETH_FLAG_RXVLAN != NETIF_F_HW_VLAN_RX).

Or implement the new features interface like every other driver...

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

