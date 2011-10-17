From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [PATCH] smsc911x: Add regulator support
Date: Mon, 17 Oct 2011 16:38:02 +0100
Message-ID: <20111017153802.GK5448@sirena.org.uk>
References: <1318834597-3479-1-git-send-email-robert.marklund@stericsson.com>
 <20111017105256.GG5448@sirena.org.uk>
 <2B1D156D95AE9B4EAD379CB9E465FE7324AB09DE76@EXDCVYMBSTM005.EQ1STM.local>
 <20111017123614.GC27266@opensource.wolfsonmicro.com>
 <2B1D156D95AE9B4EAD379CB9E465FE7324AB09E052@EXDCVYMBSTM005.EQ1STM.local>
 <20111017143358.GI5448@sirena.org.uk>
 <2B1D156D95AE9B4EAD379CB9E465FE7324AB09E0EE@EXDCVYMBSTM005.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Mathieu Poirer <mathieu.poirier@linaro.org>
To: Robert MARKLUND <robert.marklund@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:46695 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751512Ab1JQPiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 11:38:05 -0400
Content-Disposition: inline
In-Reply-To: <2B1D156D95AE9B4EAD379CB9E465FE7324AB09E0EE@EXDCVYMBSTM005.EQ1STM.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 17, 2011 at 05:28:08PM +0200, Robert MARKLUND wrote:

> > If we fail to grab a critical resource for the device like the power
> > supply then we should be failing passing the error back.  As I keep
> > saying this is what all the other regulator consumers are doing.

> Most of the boards out there don't have any regulators for the chip(power is always on).
> So when we can't get the regulator, we assume that the power is already on.
> That's why it hasn't been implemented before.

> So adding this functionality will make all the other boards out there fail, to start the driver.

Clearly this issue is going to apply to every single user of the
regulator API which is one reason why it's insane to open code handling
of missing regulators in individual regulator consumer drivers.  As I
keep saying you should unconditionally use the regulators and let the
regulator API facilities for stubbing itself out deal with this.
