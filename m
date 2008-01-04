From: David Miller <davem@davemloft.net>
Subject: Re: NAPI poll behavior in various Intel drivers
Date: Fri, 04 Jan 2008 13:24:43 -0800 (PST)
Message-ID: <20080104.132443.25068269.davem@davemloft.net>
References: <20080104.034036.160194618.davem@davemloft.net>
	<477E92B6.8010809@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, auke-jan.h.kok@intel.com
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46717
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754150AbYADVYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 16:24:43 -0500
In-Reply-To: <477E92B6.8010809@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Fri, 04 Jan 2008 20:10:30 +0000

> With the latest NAPI, this code has to change. But rather than remove
> the tx_cleaned logic completely, shouldn't transmit processing be
> included in the work_done accounting when a driver does transmit cleanup
> processing in the poll?

Most other NAPI drivers don't do this, they just process all the
pending TX work unconditionally and do not account it into the NAPI
poll work.

The logic is that, like link state handling, TX work is very cheap and
not the cpu cycle eater that RX packet processing is.
