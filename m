From: Mark Brown <broonie@sirena.org.uk>
Subject: Re: [PATCH] natsemi: Messages being noisy
Date: Fri, 15 Sep 2006 11:52:36 +0100
Message-ID: <20060915105232.GA3645@sirena.org.uk>
References: <200609131528.51336.netdev@axxeo.de> <200609141739.08461.netdev@axxeo.de> <20060914154607.GA7576@hockin.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Oeser <netdev@axxeo.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:10256 "EHLO
	cassiel.sirena.org.uk") by vger.kernel.org with ESMTP
	id S1751254AbWIOK6E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Sep 2006 06:58:04 -0400
To: thockin@hockin.org
Content-Disposition: inline
In-Reply-To: <20060914154607.GA7576@hockin.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 14, 2006 at 08:46:07AM -0700, thockin@hockin.org wrote:
> On Thu, Sep 14, 2006 at 05:39:08PM +0200, Ingo Oeser wrote:

> > Is it possible to have the maximum value right from the start?
> > May I tune it somewhere to be the maximum from the start?

> This will (if I recall) increase transmit latency.  It's a fine line.  You
> might tune it up, but this fallback path probably should not be removed..

Yes, raising the limit there will increase transmit latency since it
causes the chip to wait for more data to be DMAed before it begins
pushing the frame out.  I guess the dropped packet could be worked
around by resubmitting the dropped packet when we reconfigure the chip,
though obviously that's not ideal.

It would be interesting to understand what caused this to start
happening.  The main change in natsemi itself between 2.6.13.4 and
2.6.16.27 is the introduction of NAPI although it could be some other
change causing PCI bandwidth to become more scarce.

-- 
"You grabbed my hand and we fell into it, like a daydream - or a fever."
