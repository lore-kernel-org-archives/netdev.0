From: Tony Lindgren <tony@atomide.com>
Subject: Re: [RFC PATCH 0/4] cpsw: support for control module register
Date: Wed, 18 Sep 2013 11:49:32 -0700
Message-ID: <20130918184931.GA9994@atomide.com>
References: <1378639438-27686-1-git-send-email-mugunthanvnm@ti.com>
 <522D8DB8.5050305@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mugunthan V N <mugunthanvnm@ti.com>, netdev@vger.kernel.org,
	davem@davemloft.net, bcousson@baylibre.com,
	devicetree-discuss@lists.ozlabs.org, linux-omap@vger.kernel.org
To: Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-03-ewr.mailhop.org ([204.13.248.66]:18043 "EHLO
	mho-01-ewr.mailhop.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751793Ab3IRSth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 14:49:37 -0400
Content-Disposition: inline
In-Reply-To: <522D8DB8.5050305@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Daniel Mack <zonque@gmail.com> [130909 02:06]:
> On 08.09.2013 13:23, Mugunthan V N wrote:
> > This patch series adds the support for configuring GMII_SEL register
> > of control module to select the phy mode type and also to configure
> > the clock source for RMII phy mode whether to use internal clock or
> > the external clock from the phy itself.
> > 
> > Till now CPSW works as this configuration is done in U-Boot and carried
> > over to the kernel. But during suspend/resume Control module tends to
> > lose its configured value for GMII_SEL register in AM33xx PG1.0, so
> > if CPSW is used in RMII or RGMII mode, on resume cpsw is not working
> > as GMII_SEL register lost its configuration values.
> > 
> > The initial version of the patch is done by Daniel Mack but as per
> > Tony's comment he wants it as a seperate driver as it is done in USB
> > control module. I have created a seperate driver for the same and as
> > the merge window is open now and no feature request is accepted I am
> > submitting it as RFC for reviews.
> 
> Thanks for doing this. It's a somehow expensive approach of writing a
> single 32bit register, but I agree it's cleaner to not have this code in
> the cpsw driver directly.

The main reason for doing that is because this register is in a
separate omap SCM (System Control Module) and may need to be
eventually a child of a SCM core driver. This is to avoid invalid
PM dependencies between separate hardware modules as they can
be clocked separately.

Most of the SCM registers can be already handled by using
pinctrl-single driver, but it's not intended for using for
transceivers etc that are not strictly pinctrl related.

Regards,

Tony
