From: Alex Sidorenko <alexandre.sidorenko@hp.com>
Subject: Re: An inconsistency/bug in ingress netem timestamps
Date: Wed, 15 Apr 2009 16:10:43 -0400
Message-ID: <200904151610.43980.alexandre.sidorenko@hp.com>
References: <20090415195022.GA3322@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:43973 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753457AbZDOUKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 16:10:46 -0400
In-Reply-To: <20090415195022.GA3322@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On April 15, 2009 03:50:22 pm Jarek Poplawski wrote:

> I agree there is an inconsistency, but it seems 100 ms isn't the
> "right" thing to show here. It shows an internal delay added on ifb by
> any packet scheduler, so probably not what a user usually expects.

Hi Jarek,

thank you for your comments. Yes, I understand that it just looked OK in this 
case even though technically the value was not quite correct.

> > The strange thing is that as soon as there is any ptype_all handler
> > installed, skb->tstamp is updated properly. Unfortunately, my knowledge
> > of TC internals is not good enough to find how exactly this happens.
>
> Isn't it when act_mirred calls dev_queue_xmit with dev_queue_xmit_nit?
> But, as above mentioned, I doubt it's "updated properly" in this case.

I can see that dev_queue_xmit_nit calls net_timestamp(skb) unconditionally. I 
agree that to fix this properly we need to update tstamp in another place 
explicitly (in ifb or netem?).

Thanks,
Alex

-- 
------------------------------------------------------------------
Alexandre Sidorenko             email: asid@hp.com
WTEC Linux			Hewlett-Packard (Canada)
------------------------------------------------------------------
