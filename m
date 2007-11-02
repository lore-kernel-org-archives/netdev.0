From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Remove unneeded type cast in skb_truesize_check()
Date: Fri, 02 Nov 2007 14:27:17 -0700 (PDT)
Message-ID: <20071102.142717.157261554.davem@davemloft.net>
References: <20071102191426.30464.7490.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chuck.lever@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51461
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752454AbXKBV1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2007 17:27:19 -0400
In-Reply-To: <20071102191426.30464.7490.stgit@manray.1015granger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 02 Nov 2007 15:14:26 -0400

> The (int) type cast in skb_truesize_check() is unneeded: without it, all
> the variable types in the conditional expression are unsigned integers.  As
> it stands, the type cast causes a comparison between a signed and an
> unsigned integer, which can produce unexpected results.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

This is checking for skb->truesize being decremented too much by other
code, which could cause a wraparound below zero, so we do want
negaitve checks here.

Please stop these mindless signedness conversions without first trying
to think about what the code might be trying to do.

Thank you.
