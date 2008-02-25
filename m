From: David Brownell <david-b@pacbell.net>
Subject: Re: [patch 2.6.25-rc3] smc91x section fix
Date: Sun, 24 Feb 2008 22:33:12 -0800
Message-ID: <200802242233.12764.david-b@pacbell.net>
References: <20080225033411.941C328DEAA@adsl-69-226-248-13.dsl.pltn13.pacbell.net> <20080225060220.GA12459@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nico@cam.org, netdev@vger.kernel.org
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp116.sbc.mail.sp1.yahoo.com ([69.147.64.89]:32601 "HELO
	smtp116.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753367AbYBYGdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 01:33:18 -0500
In-Reply-To: <20080225060220.GA12459@uranus.ravnborg.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 24 February 2008, Sam Ravnborg wrote:

> From a quick look this is wrong.
> smc_drv_probe is assined the .probe member so it is used during
> hotplug and thus should be __devinit.
> Likewise smc_probe is used by smc_drv_probe and thus smc_probe
> should be __devinit too.

Thing is, with only rare exceptions, devices on the platform
bus are *NOT* hotpluggable.  So using __devinit/__devexit and
friends adds up to no more than a waste of I-space.

Nico may know if this driver is one of the rare exceptions.
Example, is it used in PCMCIA cards?

See also platform_driver_probe(), which is a much safer way
to handle such issues.  I've seen it save a full page in some
drivers, but usually it's less.

- Dave
