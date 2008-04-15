From: Andy Furniss <lists@andyfurniss.entadsl.com>
Subject: Re: [PATCH 2/7] ATM cell alignment.
Date: Wed, 16 Apr 2008 00:41:57 +0100
Message-ID: <48053D45.40307@andyfurniss.entadsl.com>
References: <Pine.LNX.4.64.0804092249550.21022@ask.diku.dk> <Pine.LNX.4.64.0804092259460.21022@ask.diku.dk> <4801ED79.5090502@andyfurniss.entadsl.com> <Pine.LNX.4.64.0804140656360.13277@ask.diku.dk>
Reply-To: lists@andyfurniss.entadsl.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.ukfsn.org ([77.75.108.10]:43833 "EHLO mail.ukfsn.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752591AbYDOXlk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 19:41:40 -0400
In-Reply-To: <Pine.LNX.4.64.0804140656360.13277@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer wrote:
> On Sun, 13 Apr 2008, Andy Furniss wrote:

>> I see overhead is unsigned short. For me using pppoa/vc mux my 
>> overhead is IP + 10. I am shaping on eth so skb->len is IP+14 hence I 
>> need a negative overhead.
> 
> I'm not completely sure I understand how you end up with a negative 
> overhead.  But I guess what you are saying, is that you need to remove 
> the MAC header from the equation is it has already been added to 
> skb->len (as you are doing routed and not bridged AAL5 encap).

Yep I think there are only two cases that will hit this one.

> 
> That makes a good point for a _seperate_ patch (by you ;-)) where we 
> change the overhead to be signed.  Or else you can do a userspace TC 
> patch that abuse the cell_align, as you mentioned below, to express a 
> negative overhead. (I'm trying to say, lets not mix these things... 
> please!)

Fair enough, I suppose doing it with overhead could be more dangerous 
for accidental user misconfiguration than just in TC.

> 
> 
>> Recently built a 2.6.25-rc7 and noticed the cell_align has been added 
>> and the tables jigged.
> 
> Yes, the tables has been aligned to 2^n and avoids underestimation. 
> Thus, with upto 2^4 (16) the table aligns to 48 bytes (ATM cell payload 
> size), standard TC uses 2^3. (If I remember correctly you, did comment 
> on the patch so you must have read it ;-)).

Hmm did I - was that the post where I wanted overhead to be bigger for 
ingress shaping - what is it with me and overhead :-)

> 
> ps. I'm currently on a roadtrip down the west-coast of USA, so I only 
> have periodic wifi coverage at different campgrounds...

Have a good holiday.

Andy.
