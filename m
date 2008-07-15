From: Travis Stratman <tstratman@emacinc.com>
Subject: Re: data received but not detected
Date: Tue, 15 Jul 2008 15:46:24 -0500
Message-ID: <1216154784.3084.151.camel@cheeto.emacinc.com>
References: <1213740538.5771.192.camel@localhost.localdomain>
	 <48583B37.5070708@candelatech.com>
	 <1213743506.5771.220.camel@localhost.localdomain>
	 <48584CAD.6010509@candelatech.com>
	 <1213915992.9245.71.camel@localhost.localdomain>
	 <485E185E.1090807@katalix.com>
	 <1215467798.14023.130.camel@localhost.localdomain>
	 <4873356F.5080402@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.emacinc.com ([63.245.244.68]:47320 "EHLO mail.emacinc.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753460AbYGOUqi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2008 16:46:38 -0400
In-Reply-To: <4873356F.5080402@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-07-08 at 10:37 +0100, James Chapman wrote:
> 
> The rx and tx status are flagged in the same status register. The bits 
> are set regardless of whether rx or tx interrupts are enabled in the 
> device. So when you handle a tx interrupt, the interrupt routine will 
> read the status register and may see rx bits also set.

That makes sense, I was making an incorrect assumption.
> 
> You could mask the status register value that you read to ignore rx bits 
> if rx interrupts are disabled (NAPI polled mode). But to be honest, I 
> think it is simpler to handle rx _and_ tx work in the NAPI poll handler 
> so you only get interrupts when not in NAPI polled mode. See tg3.c or 
> e100.c for example.

I will take a look at modifying the driver to use NAPI for tx.

Thanks,

Travis

