From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [XFRM] AUDIT: Fix audit buffer leakage in error path.
Date: Mon, 12 Feb 2007 15:23:17 -0800 (PST)
Message-ID: <20070212.152317.92582928.davem@davemloft.net>
References: <20070213.003429.73173216.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35290
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030480AbXBLXXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 18:23:18 -0500
In-Reply-To: <20070213.003429.73173216.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 13 Feb 2007 00:34:29 +0900 (JST)

> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Oh yes.  I noticed this too while working with Joy Latten's OOPS fix
for this function.

Event types other than those 4 mentioned in the switch() statement are
illegal and should never be passed in.  It is probably better to BUG()
on this situation rather than try to handle the log buffer leakage.
