From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: TCP 2MSL on loopback
Date: Tue, 6 Mar 2007 14:54:03 -0800
Message-ID: <20070306145403.6be2c437@freekitty>
References: <45EDD17F.5000203@cosmosbay.com>
	<45EDD791.4040908@symas.com>
	<45EDDC4F.7010201@hp.com>
	<20070306.133516.104036428.davem@davemloft.net>
	<45EDE60D.1030706@symas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	dada1@cosmosbay.com, netdev@vger.kernel.org
To: Howard Chu <hyc@symas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34748 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030428AbXCFWzS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 17:55:18 -0500
In-Reply-To: <45EDE60D.1030706@symas.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 06 Mar 2007 14:07:09 -0800
Howard Chu <hyc@symas.com> wrote:

> David Miller wrote:
> > From: Rick Jones <rick.jones2@hp.com>
> > Date: Tue, 06 Mar 2007 13:25:35 -0800
> > 
> >>> On the other hand, being able to configure a small MSL for the loopback 
> >>> device is perfectly safe. Being able to configure a small MSL for other 
> >>> interfaces may be safe, depending on the rest of the network layout.
> >> A peanut gallery question - I seem to recall prior discussions about how 
> >> one cannot assume that a packet destined for a given IP address will 
> >> remain detined for that given IP address as it could go through a module 
> >> that will rewrite headers etc.
> > 
> > That's right, both netfilter and the packet scheduler actions
> > can do that, that's why this whole idea about changing the MSL
> > on loopback by default is wrong and pointless.
> 
> If the headers get rewritten and the packet gets directed elsewhere, 
> then we're no longer talking about a loopback connection, so that's 
> outside the discussion.
> 
> If the packet gets munged by multiple filters but still eventually gets 
> to the specified destination, OK. But regardless, if both endpoints of 
> the connection are on the loopback device, then there is nothing wrong 
> with the idea. Those filters can only do so much, they still have to 
> preserve the reliable in-order delivery semantics of TCP, otherwise the 
> system is broken.
> 
> It may not have much use, sure, I admitted that much from the outset.
> 
> So I'll leave it at this, thanks for the feedback.


TCP can not assume anything about the path that a packet may take.
We have declared a moratorium on loopback benchmark foolishness.
Go optimize the idle loop instead ;-)

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
