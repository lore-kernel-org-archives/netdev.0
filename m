From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] net: add destructor for skb data.
Date: Sun, 6 Apr 2008 13:20:18 +0400
Message-ID: <20080406092018.GA32293@2ka.mipt.ru>
References: <200804052156.05318.rusty@rustcorp.com.au> <20080405130647.GA21337@2ka.mipt.ru> <200804061320.59485.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:42568 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751579AbYDFJUc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Apr 2008 05:20:32 -0400
Content-Disposition: inline
In-Reply-To: <200804061320.59485.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rusty.

On Sun, Apr 06, 2008 at 01:20:59PM +1000, Rusty Russell (rusty@rustcorp.com.au) wrote:
>     I don't think so.  For a start, the skb destructor is called while the skb 
> is still in the socket queue (ie. the data is still live).  Secondly, the 
> original skb can be freed while clones still reference the data.

That is what it is for - to remove data from any queues and free it.
One can check if skb was cloned and do not perform some steps, instead
call old destructor. Destructor for the last clone will cleanup whatever
is needed. Thoughts?

Actually I'm not that opposed agains additional destructor, I just want
to bring attention to this topic, since this is second time some steps
are going to be setup for the destruction time, so I want a clear
solution :)

-- 
	Evgeniy Polyakov
