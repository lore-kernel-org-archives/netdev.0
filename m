From: "Bedia, Vaibhav" <vaibhav.bedia@ti.com>
Subject: RE: [PATCH] net: davinci_emac: Add pre_open, post_stop platform
 callbacks
Date: Thu, 3 May 2012 10:44:44 +0000
Message-ID: <B5906170F1614E41A8A28DE3B8D121433EA72820@DBDE01.ent.ti.com>
References: <20120502234718.GA5432@animalcreek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: "Mark A. Greer" <mgreer@animalcreek.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:55742 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754080Ab2ECKpZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 06:45:25 -0400
In-Reply-To: <20120502234718.GA5432@animalcreek.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 03, 2012 at 05:17:18, Mark A. Greer wrote:
> From: "Mark A. Greer" <mgreer@animalcreek.com>
> 
> The davinci EMAC driver has been incorporated into the am35x
> family of SoC's which is OMAP-based.  The incorporation is
> incomplete in that the EMAC cannot unblock the [ARM] core if
> its blocked on a 'wfi' instruction.  This is an issue with
> the cpu_idle code because it has the core execute a 'wfi'
> instruction.
> 
> To work around this issue, add platform data callbacks which
> are called at the beginning of the open routine and at the
> end of the stop routine of the davinci_emac driver.  The
> callbacks allow the platform code to issue disable_hlt() and
> enable_hlt() calls appropriately.  Calling disable_hlt()
> prevents cpu_idle from issuing the 'wfi' instruction.
> 
> It is not sufficient to simply call disable_hlt() when
> there is an EMAC present because it could be present but
> not actually used in which case, we do want the 'wfi' to
> be executed.
> 

Are you trying to say that if ARM executes _just_ wfi and _absolutely
nothing else_ is done in the OMAP PM code, EMAC stops working?

However, if this is indeed the case, then probably a better solution would be
to invoke disable_hlt() from the board file when EMAC support is compiled in.

Regards,
Vaibhav
