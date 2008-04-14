From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH 2/7] ATM cell alignment.
Date: Mon, 14 Apr 2008 07:59:53 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0804140656360.13277@ask.diku.dk>
References: <Pine.LNX.4.64.0804092249550.21022@ask.diku.dk>
 <Pine.LNX.4.64.0804092259460.21022@ask.diku.dk> <4801ED79.5090502@andyfurniss.entadsl.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Andy Furniss <lists@andyfurniss.entadsl.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:43547 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753083AbYDNF75 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 01:59:57 -0400
In-Reply-To: <4801ED79.5090502@andyfurniss.entadsl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 13 Apr 2008, Andy Furniss wrote:

> Jesper Dangaard Brouer wrote:
>
>>  + The align to ATM cells is used for determining the (ATM) SAR
>>  + alignment overhead at the ATM layer. (SAR = Segmentation And
>>  + Reassembly).  This is for example needed when scheduling packet on an
>>  + ADSL connection.  Note that the extra ATM-AAL overhead is _not_
>>  + included in this calculation. This overhead is added in the kernel
>>  + before doing the rate table lookup, as this gives better precision
>>  + (as the table will always be aligned for 48 bytes).
>
> I see overhead is unsigned short. For me using pppoa/vc mux my overhead is IP 
> + 10. I am shaping on eth so skb->len is IP+14 hence I need a negative 
> overhead.

I'm not completely sure I understand how you end up with a negative 
overhead.  But I guess what you are saying, is that you need to remove the 
MAC header from the equation is it has already been added to skb->len (as 
you are doing routed and not bridged AAL5 encap).

That makes a good point for a _seperate_ patch (by you ;-)) where we 
change the overhead to be signed.  Or else you can do a userspace TC patch 
that abuse the cell_align, as you mentioned below, to express a negative 
overhead. (I'm trying to say, lets not mix these things... please!)


> Recently built a 2.6.25-rc7 and noticed the cell_align has been added and the 
> tables jigged.

Yes, the tables has been aligned to 2^n and avoids underestimation. 
Thus, with upto 2^4 (16) the table aligns to 48 bytes (ATM cell payload 
size), standard TC uses 2^3. (If I remember correctly you, did comment on 
the patch so you must have read it ;-)).


> I am (ab)using this at -5 now. Handy that I only need to patch TC rather 
> than kernel and I guess I could use other TCs if I needed to shape other 
> not atm ifs.

Yes, its nice that we have added this kind of flexibility to the kernel...


> Russel Stuart's patches handled this case IIRC, has it been lost or have I 
> missed something (as usual)?

I don't think so, but I'm not sure about that... I think it was way too 
complex, which will make it difficult to maintain in the future.

Cheers,
   Jesper Brouer

ps. I'm currently on a roadtrip down the west-coast of USA, so I only have 
periodic wifi coverage at different campgrounds...

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
