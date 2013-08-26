From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH v6 2/5] net: ethernet: cpsw: add optional third memory
 region for CONTROL module
Date: Mon, 26 Aug 2013 02:04:23 -0700
Message-ID: <20130826090422.GB7656@atomide.com>
References: <1377286330-29663-1-git-send-email-zonque@gmail.com>
 <1377286330-29663-3-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bcousson@baylibre.com, nsekhar@ti.com,
	sergei.shtylyov@cogentembedded.com, davem@davemloft.net,
	ujhelyi.m@gmail.com, mugunthanvnm@ti.com, vaibhav.bedia@ti.com,
	d-gerlach@ti.com, linux-arm-kernel@lists.infradead.org,
	linux-omap@vger.kernel.org, devicetree@vger.kernel.org
To: Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-02-ewr.mailhop.org ([204.13.248.72]:27912 "EHLO
	mho-02-ewr.mailhop.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751391Ab3HZJEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Aug 2013 05:04:30 -0400
Content-Disposition: inline
In-Reply-To: <1377286330-29663-3-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Daniel Mack <zonque@gmail.com> [130823 12:39]:
> At least the AM33xx SoC has a control module register to configure
> details such as the hardware ethernet interface mode.
> 
> I'm not sure whether all SoCs which feature the cpsw block have such a
> register, so that third memory region is considered optional for now.

Assuming you're talking about omap SCM registers here..

This should be in a separate driver module so the control module
parts can eventually be children of the SCM driver as they are
really separate devices on the bus. See how the USB PHY parts were done
for example.

What do these control module registers do? If it's just multiplexing
and pinconf, then you can use pinctrl-single,bits most likely for it and
access it using the named modes.

However, if the register also contains comparators and control for
regulators, you should only use pinctrl-single for the multiplexing
and pinconf parts.

Regards,

Tony
