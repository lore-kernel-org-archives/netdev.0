From: Russell Stuart <russell-tcatm@stuart.id.au>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL (RTAB
	BUG)
Date: Thu, 20 Jul 2006 15:47:54 +1000
Message-ID: <1153374474.4231.103.camel@ras.pc.brisbane.lube>
References: <1150843471.17455.2.camel@ras.pc.brisbane.lube>
	 <15653CE98281AD4FBD7F70BCEE3666E53CD54A@comxexch01.comx.local>
	 <1151000966.5392.34.camel@jzny2>
	 <1151066247.4217.254.camel@ras.pc.brisbane.lube>
	 <1151158431.6716.95.camel@jzny2>
	 <1153188409.13145.5.camel@ras.pc.brisbane.lube>
	 <44BD56A4.9090002@andyfurniss.entadsl.com>
	 <1153270932.4242.60.camel@ras.pc.brisbane.lube>
	 <44BE44E3.9080100@andyfurniss.entadsl.com>
	 <Pine.LNX.4.61.0607192114240.9570@tyr.diku.dk>
	 <20060719210004.GB20264@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Andy Furniss <lists@andyfurniss.entadsl.com>, hadi@cyberus.ca,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 58.105.229.78.optusnet.com.au ([58.105.229.78]:59816 "EHLO
	adsl-kenny.stuart.id.au") by vger.kernel.org with ESMTP
	id S1030272AbWGTFtC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jul 2006 01:49:02 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060719210004.GB20264@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-07-20 at 01:00 +0400, Alexey Kuznetsov wrote:
> Hello!

So you really do exist?  I thought it was just
rumour.

> Well, if fixed point arithmetics is not a problem.

It shouldn't be.  Any decimal number can be expressed
as a fraction, eg:

  0.00123 = 123/100000

Which can be calculated as a multiply and a divide. With
MTU's up to 2048, it should be possible to do this with
99.9999% accuracy (ie 2048/2^23).

With a bit more work in userspace (ie in tc), it can be
be reduced to a multiply and a shift.

> Plus, remember, the function is not R*size, it is at least
> R*size+addend, to account for link overhead. Plus account for padding
> of small packets. Plus, when policing it should deaccount already added
> link headers, QoS counts only network payload.

Yes, it is flexible - and has served us well up until
now.  It doesn't work well for ATM, but with a small
bit of extra calculation in the kernel it could.
However, it turns out that ATM is a special case.  If 
ATM's cell payload was 58 bytes instead of 48 bytes 
(say), then it would not be possible to produce a RTAB 
that had small errors (eg < 10%) for smallish packet 
sizes (< 290 bytes).  I seem to have trouble 
explaining why in a concise way that people understand, 
so I won't try here.

So when Alan Cox said our ATM patch didn't solve the 
packetisation problem in general, he was right as our
patch just built upon RTAB.  Patrick's STAB proposal 
in general either for that matter, as it is just another 
implementation of RTAB with the same limitations.  The 
only way I can think of to solve it in general is to 
move many more calculations into the kernel - as I 
proposed in a long winded answer to Patrick earlier 
in this thread.

But doing so would get rid of the table implementation 
and the flexibility it has given us to date.  For that 
reason I feel uncomfortable with it.

The engineering decision becomes this - are there any
other protocols like ATM out there that could justify 
such a change?  (In my more cynical moments I think of 
it differently - has/is the world going to make a 
second engineering fuck up on the scale of ATM again?  
How on earth did anyone decide that pushing data 
packets over ATM, as happens in ADSL, was a good 
idea?)  I know of no other such protocols.  But then
I don't have an encyclopedic knowledge of comms
protocols, so that doesn't mean much.  I suspect you
know a good deal more about them than I do.  What say
you?

