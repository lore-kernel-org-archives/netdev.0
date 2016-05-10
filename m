From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFT 1/2] phylib: add device reset GPIO support
Date: Tue, 10 May 2016 11:32:47 -0700
Message-ID: <5732294F.3060606@gmail.com>
References: <81129033.NXiOLTg1so@wasted.cogentembedded.com>
 <3641492.klKRrvS8tr@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	grant.likely@linaro.org, robh+dt@kernel.org,
	devicetree@vger.kernel.org, netdev@vger.kernel.org,
	frowand.list@gmail.com, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34881 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751642AbcEJScu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 14:32:50 -0400
In-Reply-To: <3641492.klKRrvS8tr@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/28/2016 03:12 PM, Sergei Shtylyov wrote:
> The PHY devices sometimes do have their reset signal (maybe even power
> supply?) tied to some GPIO and sometimes it also does happen that a boot
> loader does not leave it deasserted. So far this issue has been attacked
> from (as I believe) a wrong angle: by teaching the MAC driver to manipulate
> the GPIO in question; that solution, when applied to the device trees, led
> to adding the PHY reset GPIO properties to the MAC device node, with one
> exception: Cadence MACB driver which could handle the "reset-gpios" prop
> in a PHY device subnode. I believe that the correct approach is to teach
> the 'phylib' to get the MDIO device reset GPIO from the device tree node
> corresponding to this device -- which this patch is doing...
> 
> Note that I had to modify the  AT803x PHY driver as it would stop working
> otherwise as it made use of the reset GPIO for its own purposes...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

This looks good to me:

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

Can you follow up with changes in phy_{suspend,resume} if that is also
an use case that you have?
-- 
Florian
