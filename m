From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] TCP FIN gets dropped prematurely, results in ack storm
Date: Tue, 1 May 2007 22:20:07 +0400
Message-ID: <20070501182006.GA12030@2ka.mipt.ru>
References: <20070501151354.GB1751@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:45160 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030752AbXEASUU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 14:20:20 -0400
Content-Disposition: inline
In-Reply-To: <20070501151354.GB1751@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 01, 2007 at 11:13:54AM -0400, Benjamin LaHaise (bcrl@kvack.org) wrote:
> Hello,
> 
> While testing a failover scenario, I managed to trigger an ack storm 
> between a Linux box and another system.  Although the cause of this particular 
> ACK storm was due to the other box forgetting that it sent out a FIN (the 
> second node was unaware of the FIN the first sent in its dying gasp, which 
> is what I'm trying to fix, but it's a tricky race), the resulting Linux 
> behaviour wasn't very robust.  Is there any particularly good reason that 

One of the packets sent by broken 1.1 host has incorrect checksum, so it
will be dropped by 2.2 system in theory, could that packet somehow break
2.2 stack's state machine?

-- 
	Evgeniy Polyakov
