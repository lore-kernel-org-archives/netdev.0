From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] net: add destructor for skb data.
Date: Mon, 7 Apr 2008 07:10:12 +1000
Message-ID: <200804070710.12490.rusty@rustcorp.com.au>
References: <200804052156.05318.rusty@rustcorp.com.au> <200804061320.59485.rusty@rustcorp.com.au> <20080406092018.GA32293@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:33763 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756253AbYDFVKe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Apr 2008 17:10:34 -0400
In-Reply-To: <20080406092018.GA32293@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 06 April 2008 19:20:18 Evgeniy Polyakov wrote:
> Hi Rusty.
>
> On Sun, Apr 06, 2008 at 01:20:59PM +1000, Rusty Russell 
(rusty@rustcorp.com.au) wrote:
> >     I don't think so.  For a start, the skb destructor is called while
> > the skb is still in the socket queue (ie. the data is still live). 
> > Secondly, the original skb can be freed while clones still reference the
> > data.
>
> That is what it is for - to remove data from any queues and free it.
> One can check if skb was cloned and do not perform some steps, instead
> call old destructor. Destructor for the last clone will cleanup whatever
> is needed. Thoughts?

The old destructor is in some other skb, you'd have to carry it around.  
And skb_orphan() calls the destructor early deliberately.

The current skb destructor is for the sk_buff, not the data.  It's clearest to 
keep them separate.

Cheers,
Rusty.
