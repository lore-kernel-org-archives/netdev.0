From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: slow tcp connect when using IPsec
Date: Fri, 25 Mar 2011 09:58:45 +0100
Message-ID: <20110325085845.GH1290@secunet.com>
References: <20110325064116.GE1290@secunet.com>
 <20110325.012749.235670347.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:54547 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752141Ab1CYI6r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Mar 2011 04:58:47 -0400
Content-Disposition: inline
In-Reply-To: <20110325.012749.235670347.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 25, 2011 at 01:27:49AM -0700, David Miller wrote:
> 
> > So now I know why it did not behave as expected, but unfortunately I
> > still don't know why it magically started to work after 20
> > seconds...
> 
> After some time, TCP will mark routing path as having trouble, then it
> will relookup the route.  At this point source and dest will no longer
> be wildcarded in the socket, and thus neither will be the resulting
> route keys in the relooked-up route.
> 
> Look for the dst_negative_advice() paths to see where this happens.

Ok, I see. Thanks for the explanation.
