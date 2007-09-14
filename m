From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [BUG] tg3 cannot do PXE (loses MAC address) after soft reboot
Date: Fri, 14 Sep 2007 10:14:20 +0200
Message-ID: <200709141014.20635.netdev@axxeo.de>
References: <20070913083918.GA5386@xanadu.blop.info> <20070913192812.GA12053@xanadu.blop.info> <1189716472.9540.106.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Lucas Nussbaum" <lucas.nussbaum@imag.fr>,
	"netdev" <netdev@vger.kernel.org>
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:4837 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751476AbXINIsj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 04:48:39 -0400
In-Reply-To: <1189716472.9540.106.camel@dell>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan schrieb:
> On Thu, 2007-09-13 at 21:28 +0200, Lucas Nussbaum wrote:
> > Erm, Wouldn't it be possible to print a warning when the driver loads,
> > saying that the firmware is outdated ?
> 
> It's possible, but would require the driver to parse the version string.
> The driver currently reports the version string for information and for
> the human to parse it.

Yes, but most humans don't know all valid firmware versions of their 
components.

Is it enough to parse the first number in the firmware via simple_strtoul()?

Then we could do this (pseudo-kernel-code :-)):


firmare_version = simple_strtoul(version_string, NULL, 0);

if (firmware_version < oldest_supported) {
	printk(KERN_WARNING "Please upgrade the firmware (you have %s, we need at least %d)\n", 
		version_string, oldest_supported);
} else if (firmware_version > newest_supported) {
	printk(KERN_INFO "Firmware version %s (latest supported: %d). You might need a newer driver.\n", 
		version_string, oldest_supported);
} else if (firmware_version != newest_supported) {
	dprintk("Firmware version %s (latest supported: %d). You might consider a firmware upgrade.\n", 
		version_string, oldest_supported);
}

Maybe that mechanism should be global somewhere? Having this kind of information available
would help system maintenance in heterogenous hardware environments.

Best regards

Ingo Oeser
