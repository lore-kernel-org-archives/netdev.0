From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH/RFC v2] introduce ARCH_CAN_UNALIGNED_ACCESS Kconfig
 symbol
Date: Thu, 20 Mar 2008 14:13:07 -0700 (PDT)
Message-ID: <20080320.141307.173590705.davem@davemloft.net>
References: <1206023695.16475.137.camel@johannes.berg>
	<20080320181310.GA17884@uranus.ravnborg.org>
	<1206038373.16475.150.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sam@ravnborg.org, dsd@gentoo.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60828
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754982AbYCTVMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 17:12:51 -0400
In-Reply-To: <1206038373.16475.150.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu, 20 Mar 2008 19:39:33 +0100

> In many cases, especially in networking, it can be beneficial to
> know at compile time whether the architecture can do unaligned
> accesses. This patch introduces a new Kconfig symbol
> 	ARCH_CAN_UNALIGNED_ACCESS
> for that purpose and adds it to the powerpc and x86 architectures.
> Also add some documentation about alignment and networking, and
> especially one intended use of this symbol.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

I think you're semantically testing the wrong thing.

It's not if unaligned accesses are supported, it's if they are
efficient enough or not.

For example, sparc64 fully handles unaligned accesses but taking the
trap to fix it up is slow.  So sparc64 "can" handle unaligned
accesses, but whether we want to set this symbol or not is another
matter.
