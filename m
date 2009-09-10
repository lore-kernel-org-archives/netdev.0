From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NIU] VLAN does not work with niu driver
Date: Wed, 09 Sep 2009 18:10:33 -0700 (PDT)
Message-ID: <20090909.181033.25374239.davem@davemloft.net>
References: <4AA819D8.1020306@Sun.COM>
	<20090909.171517.34998160.davem@davemloft.net>
	<4AA84FE3.6030407@sun.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Joyce.Yu@Sun.COM, netdev@vger.kernel.org
To: Matheos.Worku@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35611
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753093AbZIJBKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 21:10:17 -0400
In-Reply-To: <4AA84FE3.6030407@sun.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matheos Worku <Matheos.Worku@Sun.COM>
Date: Wed, 09 Sep 2009 18:01:23 -0700

> The frame type in NIU HW is embedded in a HW header, so it is possible
> to check the HW header and decide whether to pull up ETH_HLEN or VLAN
> header size of bytes. However, considering the amount of work required
> to get and examine the HW header (including endianess issues), we
> thought pulling up 64 bytes by default (as used in cassini.c) would be
> efficient.

Well, it was 64 in early versions of the driver, and I decreased it
down to ETH_HLEN.

The less the better since for forwarding applications anything past
the IPV4 header pulled is going to be a waste of CPU cache lines and
thus negatively effect forwarding rates.

That's why I asked if this change was performance regression tested,
because I know it's going to slow down forwarding rates for small
packets.
