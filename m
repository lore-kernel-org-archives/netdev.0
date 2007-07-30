From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/2] HW VLAN filtering control
Date: Mon, 30 Jul 2007 14:43:56 +0200
Message-ID: <46ADDD0C.7020200@trash.net>
References: <1185569723.28574.8.camel@strongmad>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mitch Williams <mitch.a.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36500 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750843AbXG3MoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 08:44:15 -0400
In-Reply-To: <1185569723.28574.8.camel@strongmad>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mitch Williams wrote:
> This patchset adds the capability to disable hardware VLAN filtering at
> runtime via the existing vconfig utility.  It's useful for debugging
> purposes.
> 
> The first patch modifies the VLAN subsystem to define the flag, and to
> support passing the flag on to the base driver.
> 
> The second patch modifies e1000 to support the flag.  Since it's only
> one function, other drivers can be easily modified to support this
> functionality.
> 
> vconfig is used without modification to enable or disable filtering:
> 	# vconfig [vlan-interface] 2 1
> will disable filtering, and
> 	# vconfig [vlan-interface] 2 0
> will enable filtering.


I think an ethtool option for this would be more consistent with
configuration of other device features and its questionable whether
new feature should be added to the ioctl interface at all. The
vlan driver could perform the necessary reconfiguration in the
FEAT_CHANGE notifier call.

