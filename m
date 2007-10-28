From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH] Fix/Rewrite of the mipsnet driver
Date: Sun, 28 Oct 2007 20:40:10 +0000
Message-ID: <20071028204010.GA16898@linux-mips.org>
References: <20071028043846.GM29176@networkno.de> <20071029002517.GB16913@linux-mips.org> <20071028200308.GB22287@networkno.de> <20071028132204.5ab09c10@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thiemo Seufer <ths@networkno.de>, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:37120 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751621AbXJ1UkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2007 16:40:22 -0400
Received: from localhost.localdomain ([127.0.0.1]:14525 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20023824AbXJ1UkU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Oct 2007 20:40:20 +0000
Content-Disposition: inline
In-Reply-To: <20071028132204.5ab09c10@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 28, 2007 at 01:22:04PM -0700, Stephen Hemminger wrote:

> > -#define MIPSNET_INTCTL_TXDONE     ((uint32_t)(1 <<  0))
> > -#define MIPSNET_INTCTL_RXDONE     ((uint32_t)(1 <<  1))
> > -#define MIPSNET_INTCTL_TESTBIT    ((uint32_t)(1 << 31))
> > -#define MIPSNET_INTCTL_ALLSOURCES	(MIPSNET_INTCTL_TXDONE | \
> > -					 MIPSNET_INTCTL_RXDONE | \
> > -					 MIPSNET_INTCTL_TESTBIT)
> 
> It is standard practice in the kernel to use u32 rather than uint32_t.

uint32_t has widely leaked in and as long as it's not used in headers
exported to userland is perfectly fine.  But if we want to achieve
consistence throughout the kernel it'll take a little witch hunt for
uint32_t and co.

> Also cast of shift is unneeded  (1u << 0) works fine.

Old sins of mipsnet.h which was just copied into mipsnet.c.  Or toothing
pains of a driver on its way to sanity.

  Ralf
