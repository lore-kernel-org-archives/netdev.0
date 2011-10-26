From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [PATCH 2/2] net/smsc911x: Add regulator support
Date: Wed, 26 Oct 2011 12:17:51 +0200
Message-ID: <20111026101750.GA2921@opensource.wolfsonmicro.com>
References: <1319616356-6391-1-git-send-email-linus.walleij@stericsson.com>
 <20111026083838.GA9157@opensource.wolfsonmicro.com>
 <4EA7D1F5.2030904@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Mathieu Poirer <mathieu.poirier@linaro.org>,
	Robert MARKLUND <robert.marklund@stericsson.com>,
	Linus Walleij <linus.walleij@linaro.org>
To: Linus Walleij <linus.walleij@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from opensource.wolfsonmicro.com ([80.75.67.52]:53392 "EHLO
	opensource.wolfsonmicro.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932603Ab1JZKRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 06:17:53 -0400
Content-Disposition: inline
In-Reply-To: <4EA7D1F5.2030904@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 26, 2011 at 11:25:09AM +0200, Linus Walleij wrote:
> On 10/26/2011 10:38 AM, Mark Brown wrote:

> >This has the same issue as last time - if you've got conditional code
> >like this in the body of the driver something is going wrong.  Unless
> >the supply is genuinely optional and might not be physically present on
> >some systems the driver should fail if it can't get it.  The regulator
> >API will stub itself out when not in use.

> That solves the issue for platforms with no regulator
> support at all.

No, it solves the problem for all platforms.

> Then we have platforms with regulator support, but no
> regulator for this hardware, because that one happens
> to be always-on in these systems.

Right, this is extremely common and is exactly what the fixed voltage
regulator is there for - if you've got an always on regulator in your
system define a fixed voltage regulator to represent it.

> Shall we have CONFIG_SMC911X select
> REGULATOR_DUMMY?

No, nothing should be selecting that.  Users can enable it for their
systems if they want it.
