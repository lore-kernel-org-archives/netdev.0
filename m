From: Daniel Mack <daniel@caiaq.de>
Subject: Re: smsc911x suspend/resume
Date: Mon, 8 Feb 2010 12:46:38 +0100
Message-ID: <20100208114638.GO9007@buzzloop.caiaq.de>
References: <4B6FDC83.9090205@compulab.co.il>
 <20100208101123.GW28972@buzzloop.caiaq.de>
 <4B6FF5E2.6060304@compulab.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Glendinning <steve.glendinning@smsc.com>,
	netdev@vger.kernel.org,
	LAKML <linux-arm-kernel@lists.infradead.org>
To: Mike Rapoport <mike@compulab.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from buzzloop.caiaq.de ([212.112.241.133]:34624 "EHLO
	buzzloop.caiaq.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009Ab0BHLqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 06:46:49 -0500
Content-Disposition: inline
In-Reply-To: <4B6FF5E2.6060304@compulab.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 08, 2010 at 01:30:42PM +0200, Mike Rapoport wrote:
> Daniel Mack wrote:
> > What happens to your supply voltages when going to suspend? When I
> > implemented the code for the smsc driver, I could only test scenarios
> > where AVDD remains stable during suspend. So the driver might need some
> > tweaks if that assumption is not true in your case. The SMSC datasheet
> > is quite comprehensive about this topic IIRC.
> 
> By AVDD you mean VDD33A?

Yes.

> Anyway, I have all the supplies except VDDVARIO shut down...
> And the datasheet is indeed comprehensively describes chip power states
> but I haven't found there anything about supplies required to stay on
> during suspend...

In fact the datasheet doesn't really state that, and the chip seems
to expect the power domains to remain switched on during suspend, and
all power switching is done internally. Also the table in "7.4 Power
Consumption (Device and System Components)" describes it like that.

So it all comes down to the question of how low-power you need to be,
and whether you need wake-on-lan or not. What's currently implemented is
D1, but adding support for D2 should be easy.

Daniel
