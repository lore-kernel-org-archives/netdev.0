From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [ETHTOOL]: Add support for large eeproms
Date: Tue, 15 Apr 2008 00:31:53 -0700 (PDT)
Message-ID: <20080415.003153.30044057.davem@davemloft.net>
References: <48007CA0.6030002@garzik.org>
	<20080414180338.GA18335@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, joe@perches.com,
	nil@google.com, thockin@google.com, matthew@wil.cx
To: msb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41584
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751850AbYDOHbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 03:31:52 -0400
In-Reply-To: <20080414180338.GA18335@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mandeep Singh Baines <msb@google.com>
Date: Mon, 14 Apr 2008 11:03:38 -0700

> Currently, it is not possible to read/write to an eeprom larger than
> 128k in size because the buffer used for temporarily storing the
> eeprom contents is allocated using kmalloc. kmalloc can only allocate
> a maximum of 128k depending on architecture.
> 
> Modified ethtool_get/set_eeprom to only allocate a page of memory and
> then copy the eeprom a page at a time.
> 
> Updated original patch as per suggestions from Joe Perches.
> 
> Signed-off-by: Mandeep Singh Baines <msb@google.com>

This looks fine on the surface.

But I wonder what we can do if we have some EEPROM implementation
that can only write the whole time at once, and thus will fail
if you try to do it in pieces?  Do we have such a case?

If so this new code could cause regressions.
