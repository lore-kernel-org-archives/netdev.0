From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH] Documentation: bindings: net: DPAA corenet binding
 document
Date: Wed, 3 Dec 2014 16:01:28 -0600
Message-ID: <1417644088.15957.235.camel@freescale.com>
References: <1417169426-11823-1-git-send-email-madalin.bucur@freescale.com>
	 <1417495189.15957.209.camel@freescale.com>
	 <BL2PR03MB545CC342CA6A408D2FD5CF6E67A0@BL2PR03MB545.namprd03.prod.outlook.com>
	 <1417561420.15957.221.camel@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Medve Emilian-EMMEDVE1 <Emilian.Medve@freescale.com>,
	Liberman Igal-B31950 <Igal.Liberman@freescale.com>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	Shaohui Xie <Shaohui.Xie@freescale.com>
To: Bucur Madalin-Cristian-B32716 <madalin.bucur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bn0105.outbound.protection.outlook.com ([157.56.110.105]:21376
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751110AbaLCWBl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 17:01:41 -0500
In-Reply-To: <1417561420.15957.221.camel@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-12-02 at 17:03 -0600, Scott Wood wrote:
> On Tue, 2014-12-02 at 06:12 -0600, Bucur Madalin-Cristian-B32716 wrote:
> > > -----Original Message-----
> > > From: Wood Scott-B07421
> > > Sent: Tuesday, December 02, 2014 6:40 AM
> > >
> > > No need for the <SoC> part.  As we previously discussed, the only
> > > purpose of this node is backwards compatibility with the U-Boot MAC
> > > address fixup -- if U-Boot doesn't look for the <SoC> version, then
> > > don't complicate things.
> > > 
> > > Though, I can't find where U-Boot references this node.  Are you sure
> > > it's not using the ethernet%d aliases like everything else, in which
> > > case why do we need this node at all?
> > > 
> > > -Scott
> > > 
> > 
> > The initial (Freescale SDK) binding document contained those compatibles,
> > not sure what the initial intent was for the <SoC> variants.
> > 
> > The "fsl,dpaa" node is of interest to the DPAA Ethernet because it is
> > the parent of the "fsl,dpa-ethernet" nodes.
> 
> I'm not interested in what the SDK binding says, or what the SDK kernel
> does.  I'm interested in whether there's a U-Boot compatibility issue,
> as was previously alleged.  If there isn't, then there's no need for
> fsl,dpaa *or* fsl,dpa-ethernet.

OK, I found the U-Boot fixup in question.  It's not for MAC addresses,
but for marking disabled ports as disabled.  It marks the dpa-ethernet
node as disabled, based on it having an fsl,fman-mac property that
points to the MAC node.

U-Boot also disables the MAC node itself, so it doesn't matter if it
doesn't find fsl,fman-mac -- except for the special case of fm1-dtsec1,
which is always kept enabled because it's used for MDIO for all ports.

Based on http://patchwork.ozlabs.org/patch/410770/ there's a separate
node for mdio, so why can't we mark the MAC disabled?  Assuming that
there's no real problem in marking the fm1-dtsec1 MAC node disabled, we
can consider this to be a bug in U-Boot which can be worked around by
having the fm1-dtsec1 mac node have an fsl,fman-mac property that points
to itself.  This property would only go on the fm1-dtsec1 mac node and
would only be in device trees for SoCs that are supported by U-Boots old
enough to not have had the bug be fixed.

-Scott
