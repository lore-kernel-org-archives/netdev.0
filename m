From: Gerd Hoffmann <kraxel@redhat.com>
Subject: Re: netfront for review
Date: Thu, 03 May 2007 09:33:43 +0200
Message-ID: <46399057.4000409@redhat.com>
References: <4637D672.5030706@goop.org> <1178077033.28659.173.camel@localhost.localdomain> <4638EAC0.7020107@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	lkml - Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Keir Fraser <Keir.Fraser@cl.cam.ac.uk>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54119 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965687AbXECHeH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2007 03:34:07 -0400
In-Reply-To: <4638EAC0.7020107@goop.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

   Hi,

> Gerd, in change 11196:b85da7cd9ea5 "front: Fix rx buffer leak when
> tearing down an interface." you added a call to
> "add_id_to_freelist(np->rx_skbs, id);".  However, rx_skbs doesn't have
> an extra entry for the list head, and there's never any corresponding
> get_id_from_freelist(np->rx_skbs).  What should it be?

The function has an effect in page flipping mode only.  It walks the 
whole list of rx skbufs (id is the loop variable ...), checks whenever 
they are handed out to the frontend driver to fill in packet data and 
not returned yet, and if so reclaim them ...

>>> +	err = xenbus_scanf(XBT_NIL, np->xbdev->otherend,
>>> +			   "feature-rx-flip", "%u", &feature_rx_flip);
>>> +	if (err != 1)
>>> +		feature_rx_flip = 1;
>>>     
>> This second one deserves a comment.  If it doesn't set feature_rx_flip
>> it's *on*?  Historical reasons
> 
> Guess so.  It defaults to flip.  I simplified the rx_copy/flip module
> parameter to a simple rx_mode=0/1, but this is preserved from the
> original.  My guess is that originally there was only flip, and copy was
> added later.

Yep, page flipping is the old (pre xen 3.0.3) way, copy was added (and 
made the default) later.

cheers,
   Gerd
