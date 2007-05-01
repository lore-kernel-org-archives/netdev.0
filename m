From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH] TCP FIN gets dropped prematurely, results in ack storm
Date: Tue, 1 May 2007 14:04:05 -0400
Message-ID: <20070501180405.GE1751@kvack.org>
References: <20070501151354.GB1751@kvack.org> <20070501162050.GB21896@2ka.mipt.ru> <20070501164935.GC1751@kvack.org> <46377EBB.6080604@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: John Heffner <jheffner@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:36906 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755233AbXEASEY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 14:04:24 -0400
Content-Disposition: inline
In-Reply-To: <46377EBB.6080604@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 01, 2007 at 01:54:03PM -0400, John Heffner wrote:
> Looking at your trace, it seems like the behavior of the test system 
> 192.168.2.2 is broken in two ways.  First, like you said it has broken 
> state in that it has forgotten that it sent the FIN.  Once you do that, 
> the connection state is corrupt and all bets are off.  It's sending an 
> out-of-window segment that's getting tossed by Linux, and Linux 
> generates an ack in response.  This is in direct RFC compliance.  The 
> second problem is that the other system is generating these broken acks 
> in response to the legitimate acks Linux is sending, causing the ack 
> war.  I can't really guess why it's doing that...

I know it's a bug, and I'm trying to fix it, but that doesn't change the 
fact that A) the system is already deployed and B) Linux is not retransmitting 
the FIN, which (from Linux's point of view) remains unacknowledged by the 
other side.  The patch might be wrong, but the goal of fixing the behaviour 
isn't.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <zyntrop@kvack.org>.
