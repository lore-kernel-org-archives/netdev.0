From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: e1000e: Fix build with CONFIG_PM disabled.
Date: Thu, 18 Mar 2010 00:51:22 +0100
Message-ID: <201003180051.23075.rjw@sisk.pl>
References: <20100316.234100.133957798.davem@davemloft.net> <201003172339.15494.rjw@sisk.pl> <1268869036.19191.92.camel@jbrandeb-mobl3.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:47496 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753841Ab0CQXsd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Mar 2010 19:48:33 -0400
In-Reply-To: <1268869036.19191.92.camel@jbrandeb-mobl3.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 18 March 2010, Jesse Brandeburg wrote:
> On Wed, 2010-03-17 at 15:39 -0700, Rafael J. Wysocki wrote:
> > On Wednesday 17 March 2010, David Miller wrote:
> > > From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
> > > Date: Wed, 17 Mar 2010 11:57:59 -0600
> > > 
> > > > But then the driver build fails again when CONFIG_PM_RUNTIME is not set.
> > > > 
> > > > drivers/net/e1000e/netdev.c: In function `e1000_runtime_resume`:
> > > > drivers/net/e1000e/netdev.c:4807: error: `struct dev_pm_info` has no member named `runtime_auto`
> > > 
> > > Ugh, can someone send me a fix for that?
> > 
> > Appended, on top of your patch.  It only moves the code around and adds
> > #ifdefs.
> 
> I know this is throwing a wrench in things, but won't this series of
> changes break a clean bisect (due to the compile errors?)

Well, it will, but reverting them doesn't actually help fix bisectability.

You'd have to "git reset --hard" to the commit preceding them and then apply
the combo patch.

Rafael
