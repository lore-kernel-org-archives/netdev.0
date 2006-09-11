From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: TG3 data corruption (TSO ?)
Date: Mon, 11 Sep 2006 09:08:51 -0700
Message-ID: <1157990931.5436.5.camel@rh4>
References: <1551EAE59135BE47B544934E30FC4FC093FB2C@NT-IRVA-0751.brcm.ad.broadcom.com>
 <1157953925.31071.413.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Segher Boessenkool" <segher@kernel.crashing.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	"Linux Kernel list" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:8976 "EHLO MMS3.broadcom.com")
	by vger.kernel.org with ESMTP id S932231AbWIKQK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2006 12:10:59 -0400
To: "Benjamin Herrenschmidt" <benh@kernel.crashing.org>
In-Reply-To: <1157953925.31071.413.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-09-11 at 15:52 +1000, Benjamin Herrenschmidt wrote:

> Looks like adding a sync to writel does fix it though... I'm trying to
> figure out which specific writel in the driver makes a difference. I'll
> then look into slicing those tcpdumps.

During runtime in the fast path, the only writel()'s we do in tg3 are to
the tx mbox, rx_mbox, and the interrupt mbox.  The interrupt mbox
shouldn't matter that much since it has no dependencies on other memory
writes before it.

