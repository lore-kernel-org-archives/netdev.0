From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 09/26] e1000: unify WoL capability detection code
Date: Tue, 29 Aug 2006 14:54:51 -0700
Message-ID: <44F4B7AB.9060306@intel.com>
References: <20060829164153.6872.1713.stgit@gitlost.site> <20060829164434.6872.82138.stgit@gitlost.site> <44F4A8C1.9020301@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	akpm@osdl.org, "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:8347 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S965439AbWH2WTL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 18:19:11 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <44F4A8C1.9020301@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Kok, Auke wrote:
>> WoL is constantly giving problems and needed a rewrite. Consolidates
>> all WoL capabilities into a single function, and disables WoL for all
>> other ports on the device except for port A.
> 
> Is this a behavior change that affects users in the field?
> 
> i.e. if they are using WoL via port B, and upgrade to this driver, their 
> setup suddenly breaks, right?

it's rather the other way around:

The problem is that the adapters involved (dual- and quad- port NIC adapters, 
not the dual port onboard adapters) have known issues (as in: wol does not 
work) with WoL on port b, c, d. Formerly the code was trying to enable WoL on 
ports that were not capable of doing so (82546, 82571). This fix explicitly 
still allows the properly working (as in: wol works correctly on port b) 
dual-port adapters that have WoL enabled for port b in the EEPROM enabled to 
function with WoL on those ports (i.e. most adapters).

The users who have those boards should have noticed that their adapter didn't 
function with WoL on those ports. This all comes back to a hardware errata that 
has been out here for a while. This patch brings the code up to spec with that. 
Now users will see that WoL will not work on those ports if they attempt to 
enable it, where previously it was enabled in software but didn't do anything.
We make sure to return -EOPNOTSUPP through ethtool as well for all cases.

Cheers

Auke
