From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usb/mcs7830: Don't use buffers from stack for USB
 transfers
Date: Tue, 20 Jan 2009 15:23:45 -0800 (PST)
Message-ID: <20090120.152345.78877396.davem@davemloft.net>
References: <200901202345.47792.arnd@arndb.de>
	<20090120.144719.120709836.davem@davemloft.net>
	<200901210017.19038.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ceggers@gmx.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40309
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756577AbZATXXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 18:23:43 -0500
In-Reply-To: <200901210017.19038.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 21 Jan 2009 00:17:18 +0100

> On Tuesday 20 January 2009, David Miller wrote:
> > +       buffer = kmalloc(size, GFP_NOIO);
> 
> GFP_NOIO seems out of place in a network driver: there is nothing
> wrong with waiting for I/O here, so plain GFP_KERNEL should be fine.

There seems to be a large precendence for this in other USB drivers,
both for networking and storage.  Probably a mutex or other locking
hierarchy issue.

Really, I would just apply this patch as-is.  It works, it's pretty
clean, and every retort has been a misunderstanding or extreme
nit-picking :-)
