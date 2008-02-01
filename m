From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Fri, 01 Feb 2008 07:06:49 -0500
Message-ID: <1201867609.4465.50.camel@localhost>
References: <20080131183322.GA4671@one.firstfloor.org>
	 <47A20CDC.5090104@trash.net> <20080131183735.GC4671@one.firstfloor.org>
	 <20080131100846.00934e25@extreme>
	 <20080131185328.GD4671@one.firstfloor.org> <47A211A0.1040502@trash.net>
	 <20080131190125.GE4671@one.firstfloor.org>
	 <D5C1322C3E673F459512FB59E0DDC32904700E40@orsmsx414.amr.corp.intel.com>
	 <20080131193406.GH4671@one.firstfloor.org>
	 <1201847738.17656.5.camel@roma.44ansell.gdt.id.au>
	 <20080201074600.GA12644@one.firstfloor.org> <47A2C985.30409@trash.net>
	 <D5C1322C3E673F459512FB59E0DDC32904737A42@orsmsx414.amr.corp.intel.com>
	 <47A2ECE9.5000103@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Andi Kleen <andi@firstfloor.org>, Glen Turner <gdt@gdt.id.au>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.181]:37858 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758240AbYBAMGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 07:06:53 -0500
Received: by py-out-1112.google.com with SMTP id u52so1585700pyb.10
        for <netdev@vger.kernel.org>; Fri, 01 Feb 2008 04:06:52 -0800 (PST)
In-Reply-To: <47A2ECE9.5000103@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-01-02 at 10:56 +0100, Patrick McHardy wrote:

> We don't want to disable TSO for cases where it makes sense, but
> who is using TBF on 10GbE? The point is that most users of qdiscs
> which are incapable of dealing with TSO without hacks or special
> configuration probably don't care, and 10GbE users know about
> ethtool *and* don't use TBF or HTB (which are probably the only
> qdiscs which actually have problems, maybe also CBQ).

Right - Essentially it is a usability issue:
People who know how to use TSO (Peter for example) will be clueful
enough to turn it on. Which means the default should be to protect the
clueless and turn it off.
On Andis approach:
Turning TSO off at netdev registration time with a warning will be a
cleaner IMO. Or alternatively introducing a kernel-config "I know what
TSO is" option which is then used at netdev registration. From a
usability perspective it would make more sense to just keep ethtool as
the only way to configure TSO. 

[I recently spent a few days helping someone debug a problem with IFB
because he was redirecting packets from an TSO netdevice and occasionaly
some multi-packet will be missed in the calculation; my answer was "turn
off TSO"; so there are more use cases for this TSO issue]. 

cheers,
jamal

