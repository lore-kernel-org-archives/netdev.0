From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch] e1000e, igbvf: fix default message level
Date: Sat, 10 Mar 2012 23:06:29 +0000
Message-ID: <1331420789.3022.100.camel@deadeye>
References: <20120310084921.GA4647@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	<e1000-devel@lists.sourceforge.net>, <netdev@vger.kernel.org>,
	<kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:55290 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752482Ab2CJXGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2012 18:06:38 -0500
In-Reply-To: <20120310084921.GA4647@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-03-10 at 11:49 +0300, Dan Carpenter wrote:
> The intent here was to enable both NETIF_MSG_DRV and NETIF_MSG_PROBE
> messages, but in the original code only the NETIF_MSG_DRV bit was set.
> 
> NETIF_MSG_DRV and NETIF_MSG_PROBE are bits 0 and 1, they are not
> supposed to be used to do a shift.  I think the confusion is because
> the msg_enable can also be controlled through ethtool which passes a bit
> number that is used to do a bit shift.
[...]

No, the ethtool interface also uses a mask.

However netif_msg_init() is commonly used to initialise the msg_enable
mask based on a module parameter that's a bit number.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
