From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Make FC, FDDI, HIPPI and TR tristate
Date: Sat, 29 Dec 2007 00:18:15 -0800 (PST)
Message-ID: <20071229.001815.09803550.davem@davemloft.net>
References: <Pine.LNX.4.64.0712282348280.29013@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: jengelh@computergmbh.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57616
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751665AbXL2ISP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2007 03:18:15 -0500
In-Reply-To: <Pine.LNX.4.64.0712282348280.29013@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@computergmbh.de>
Date: Sat, 29 Dec 2007 00:45:12 +0100 (CET)

> Turn CONFIG_FC, CONFIG_FDDI, CONFIG_HIPPI and CONFIG_TR into tristate
> so they can be built as modules. This will allow CONFIG_LLC to be
> built as a module too, overall reducing the core kernel image size.

You can't just do things like this.

Now, you have to go over the whole tree and look for
CONFIG_FOO ifdefs in this group and change them all into:

#if defined(CONFIG_FOO) || defined(CONFIG_FOO_MODULE)

as we already do for things like IPV6.

This is most important in cases where these ifdefs
guard inclusion of members into core networking
datastructures, or control the definition of global
CPP macro defines, etc.

One particular instance that needs fixing is the
CONFIG_TR ifdef check in include/linux/netdevice.h

I'd like you to grep over the whole tree looking for
other potential problems like this before resubmitting
this patch.
