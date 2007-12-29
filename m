From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Make FC, FDDI, HIPPI and TR tristate
Date: Sat, 29 Dec 2007 00:19:53 -0800 (PST)
Message-ID: <20071229.001953.136541622.davem@davemloft.net>
References: <Pine.LNX.4.64.0712282348280.29013@fbirervta.pbzchgretzou.qr>
	<20071229000930.GD9105@does.not.exist>
	<Pine.LNX.4.64.0712290140090.29013@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@kernel.org, jgarzik@pobox.com, netdev@vger.kernel.org
To: jengelh@computergmbh.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42333
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751837AbXL2ITy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2007 03:19:54 -0500
In-Reply-To: <Pine.LNX.4.64.0712290140090.29013@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@computergmbh.de>
Date: Sat, 29 Dec 2007 01:41:23 +0100 (CET)

> 
> On Dec 29 2007 02:09, Adrian Bunk wrote:
> >On Sat, Dec 29, 2007 at 12:45:12AM +0100, Jan Engelhardt wrote:
> >> Turn CONFIG_FC, CONFIG_FDDI, CONFIG_HIPPI and CONFIG_TR into tristate
> >> so they can be built as modules. This will allow CONFIG_LLC to be
> >> built as a module too, overall reducing the core kernel image size.
> >>...
> >
> >Just an example of code you have to fix if you do this:
> >
> >$ grep -r "#ifdef CONFIG_TR" net/
> 
> Ah, thank you for reminding me. For lec.c, would it be ok to do
> 
> #if defined(CONFIG_TR) || defined(CONFIG_TR_MODULE)
> #	define WITH_TR 1
> #endif

We don't have a WITH_IPV6, we open code the ifdef check
all over the tree.

For consistency you should do that here too.  Please don't
add new ad-hoc macros to deal with situations like this.
If it's really a problem it should be handled globally in
the confines of the config system, not on a case-by-case
basis.
