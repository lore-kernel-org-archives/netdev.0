From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] New Qlogic 10Gb Ethernet driver for 2.6.28
Date: Mon, 25 Aug 2008 14:05:22 -0700 (PDT)
Message-ID: <20080825.140522.192264181.davem@davemloft.net>
References: <20080822174626.GC2551@susedev.qlogic.org>
	<20080822.144343.231567307.davem@davemloft.net>
	<20080825170148.GA31059@susedev.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, Linux-Driver@qlogic.com, netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33428
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751526AbYHYVF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 17:05:26 -0400
In-Reply-To: <20080825170148.GA31059@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Mon, 25 Aug 2008 10:01:48 -0700

> I see your point.  I will add the re-alignment but would like to jump
> over it for platforms that don't need it.  Is there a list somewhere of
> the RISC platforms that take a trap on unaligned accesses?  Or better
> yet, a list of those that don't?

If you're only doing this for the header portion it's not so
much of a cost.  For sizable packets you're using page
references, and you don't have to copy those, such copies
of the headers will also warm up the CPU cache as a nice
side effect.

Furthermore you stated that the alignment restriction only
is necessary for early revisions of the hardware.

Please, I do not want to give you a list of platform names
to ifdef up your driver with, that's messy.  Just make the
copy when necessary to align things properly.
