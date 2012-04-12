From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 1/4 (V3)] net: ethtool: add the EEE support
Date: Thu, 12 Apr 2012 23:26:38 +0100
Message-ID: <1334269598.2497.50.camel@bwh-desktop.uk.solarflarecom.com>
References: <1333704559-11251-1-git-send-email-peppe.cavallaro@st.com>
	 <1333704559-11251-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <rayagond@vayavyalabs.com>,
	<davem@davemloft.net>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:49370 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S934122Ab2DLW0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 18:26:42 -0400
In-Reply-To: <1333704559-11251-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-04-06 at 11:29 +0200, Giuseppe CAVALLARO wrote:
> This patch adds two new functions to detect if Energy-Efficient
> Ethernet (EEE) is supported and the way to enable/disable it.
> 
> As Ben said, it is certainly necessary to distinguish:
> 
> a. PHY is advertising EEE from
> b. Link partner is advertising EEE
> or
> c. EEE will be used (= a && b)
> 
> The logic behind this code, is that .get_eee will pass
> to the user-space if the EEE is actually used and available (so point c).
> The .set_eee should used to force the MAC to disable/enable the EEE (if
> actually supported by MAC+PHY).
[...]

What I meant is that userland should be able to find out (a), and,
*separately*, either (b) or (c).  That is, there must be at least 2
separate flags for this.  In fact, I explicitly requested you define
supported/advertising/lp_advertising bitmasks for EEE link modes just
like we have for autonegotiation.  But you've made no substantive
changes in response to my review, aside from dropping the added field in
ethtool_cmd.

What you're submitting just isn't good enough for a generic interface,
as the ethtool API is supposed to be.  It's not even a good interface to
your driver.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
