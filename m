From: David Miller <davem@davemloft.net>
Subject: Re: [patch 4/4] tcp: statistics not read_mostly
Date: Mon, 12 Mar 2007 14:15:50 -0700 (PDT)
Message-ID: <20070312.141550.48806100.davem@davemloft.net>
References: <20070312210817.485320783@linux-foundation.org>
	<20070312210907.925541692@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60638
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752448AbXCLVPv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 17:15:51 -0400
In-Reply-To: <20070312210907.925541692@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Mon, 12 Mar 2007 14:08:21 -0700

> The TCP statistics shouldn't be located in the middle of the
> read_mostly section surrounded by sysctl values.
> Move EXPORT_SYMBOL next to data like other declarations near by.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Stephen, they are pointers to the statistics, not the statistic
counters themselves.  We're marking the _pointers_ as __read_mostly
here.

When Eric originally submitted the change to add __read_mostly here I
didn't understand it either.

Look at the definition of DEFINE_SNMP_STAT().
