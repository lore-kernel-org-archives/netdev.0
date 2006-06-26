From: Russell Stuart <russell@stuart.id.au>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Mon, 26 Jun 2006 14:23:27 +1000
Message-ID: <449F613F.7030700@stuart.id.au>
References: <1150278004.26181.35.camel@localhost.localdomain>	 <1150286766.5233.15.camel@jzny2>	 <1150287983.3246.27.camel@ras.pc.brisbane.lube>	 <1150292693.5197.1.camel@jzny2>	 <1150843471.17455.2.camel@ras.pc.brisbane.lube>	 <15653CE98281AD4FBD7F70BCEE3666E53CD54A@comxexch01.comx.local>	 <1151000966.5392.34.camel@jzny2>	 <1151066247.4217.254.camel@ras.pc.brisbane.lube> <1151158431.6716.95.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Russell Stuart <russell-tcatm@stuart.id.au>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 58.105.229.78.optusnet.com.au ([58.105.229.78]:54194 "EHLO
	adsl-kenny.stuart.id.au") by vger.kernel.org with ESMTP
	id S965020AbWFZEYX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 00:24:23 -0400
To: hadi@cyberus.ca
In-Reply-To: <1151158431.6716.95.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 25/06/2006 12:13 AM, jamal wrote:
> You can actually stop reading here if you have gathered the view at
> this point that i am not objecting to the simple approach Patrick is
> going with...

Perhaps this is my problem.  I am not sure I understand
what Patrick is proposing.  I can wait for his patch, I
guess.

> Indeed and i referred to it in the exchanges. 
> And yes, I was arguing that the tc scheme you describe would not be so
> bad either if the cost of making a generic change is expensive.

OK.  I take it from this you think there is merit in
the idea of adding code so the kernel can calculate
the ATM link speeds correctly.  The discussion is
really about the best way to go about it?

If so, excellent.  I am not really too fussy about how
it is achieved, I just want my VOIP connections to
work well on stock kernels.

> There are a lot of link layer issues that you may end up knowing of
> (other than the ATM fragmentation overhead) in regards to something
> downstream and you keep adding knobs is just adding more bloat. 
> Example: If that 3rd hop was wireless that happened to be doing CDMA RLP
> with a lot of retransmits, or wireless that varied its throughput from
> 1-3Mbps at any point in time or it was a satellite link that had a lot
> of latency etc etc. You could always have some way to tweak these via
> the kernel. In-fact people have written schedulers specifically for
> these sorts of link layer problems (I think even some of the IEEE 802.11
> or wimax folks have standardized specific schedulers). You basically
> have to draw a line somewhere. My line was "can it be done via user
> space? yes - do it there".

If you mean by adding lots of knobs, you mean we need a knob
for 802.11, a knob for ATM, a knob for ethernet and so on,
then we do need lots of knobs.  And you need to know which
of those layers is the bottle neck, so you know what knob to
fit.  But you only ever need one knob on a given link.

I can only think of two ways out of needing lots of knobs.
One is to have a qdisc that doesn't need to know the link
speed in order to shape traffic to it gets to the scheduling
and not someone upstream.  Sounds like black magic to me,
but perhaps HFSC does this - I have not read the papers
yet, but I plan to do so soon.

The second way is to automatically calculate the link speed,
using a daemon perhaps :).  Again it sounds like black
magic.  Note that there is already code in the kernel that
does this, but it lives in the layers above - in TCP and
DCCP.  I am referring to Westwood, and friends.  These
algorithms live in the layers above because the need feed
back from the network - which can only come from the other
end of connection unless ECN is working.

I have not been able to figure out how Patrick intends to
solve these problems from his posts so far, so I am waiting
for his code.  Hopefully it will include a lot of comments.

> Patrick seems to have a simple way to compensate generically for link
> layer fragmentation, so i will not argue the practically; hopefully that
> settles it? ;->

Yes, it does.  It will be interesting to see what Patrick
comes up with.
