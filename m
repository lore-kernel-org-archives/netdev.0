From: David Miller <davem@davemloft.net>
Subject: Re: hardware time stamping with optional structs in data area
Date: Sun, 25 Jan 2009 21:04:42 -0800 (PST)
Message-ID: <20090125.210442.129666692.davem@davemloft.net>
References: <1232102164.18762.72.camel@pohly-MOBL>
	<20090116.110033.163815590.davem@davemloft.net>
	<1232532457.7829.19.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-api@vger.kernel.org
To: patrick.ohly@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45293
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750728AbZAZFEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 00:04:40 -0500
In-Reply-To: <1232532457.7829.19.camel@ecld0pohly>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick Ohly <patrick.ohly@intel.com>
Date: Wed, 21 Jan 2009 11:07:37 +0100

> I tested them with the modified PTPd with and without hardware support
> on x86. With 64 bit kernel and user space both works. With 32 bit user
> space on a 64 bit kernel software-only time stamping works (thanks to
> the socket's compatibility layer), hardware support doesn't: the ifreq
> is passed to the right device driver, but the data pointer from a 32 bit
> process is not interpreted correctly by a 64 bit driver. If there is a
> way to handle this then please let me know - I didn't see how a device
> driver could distinguish between a 32 and 64 bit user process.

See fs/compat_ioctl.c:dev_ifsioc() for how to handle the
"32-bit process under 64-bit kernel" issue wrt. struct ifreq

Next, I don't like that loop in the SKB allocator to deal with the
variable size.  You're computing what amounts to a constant
calculation.

Just consolidate the array into a direct conversion table.  You only
have 2 bits defined so you only need an array of 4 entries.  Pass the
optional flag bits directly in as the index of that table.
