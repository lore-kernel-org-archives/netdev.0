From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NETIF_F_LLTX for devices 2
Date: 11 Sep 2004 16:15:32 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1094933731.2343.109.camel@jzny.localdomain>
References: <20040908065152.GC27886@wotan.suse.de>
	 <E1C4wYe-0005qT-00@gondolin.me.apana.org.au>
	 <20040908072408.GI27886@wotan.suse.de>
	 <1094629677.1089.155.camel@jzny.localdomain>
	 <20040908134713.1bcd46d3.davem@davemloft.net>
	 <1094823215.1121.129.camel@jzny.localdomain>
	 <20040911142116.GL4431@wotan.suse.de>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, herbert@gondor.apana.org.au,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040911142116.GL4431@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2004-09-11 at 10:21, Andi Kleen wrote:
> On Fri, Sep 10, 2004 at 09:33:35AM -0400, jamal wrote:

> > 
> > I am not 100% happy but let me do some testing on it. Would the best
> > image be the latest bk snapshot?
> 
> What exactly are you not happy about?
> 

Grr, Andi, Did you really have to force me to explain why i am unhappy?
As a general principle i  think it is against human nature to be happy. 
In this specific case, though:
Remember that famous movie breakup line "its just me not you"? 
Well, this is along those lines;-> I am not as conservative as say
Donald Becker, but it worries me messing with code that might have
repurcassions (as innocent as that code seems). It doesnt help that
recently theres more breakages in the netsched code than there have been
in the last few years put together.
If Alexey(who knows that piece of code better than anybody) was awake
and he ACKed i wouldnt be commenting. 

Having said that, when i saw your patch with the comment:
/* 	hard_start_xmit returns: 
 	0  device not ready
 	1  everything ok
 	-1 didn't get device lock (for LLTX)
*/

my mythical level of unhapiness went up;-> 
Clearly for 0 and 1 your comments are misleading/wrong (even though your
code does the right thing).

If i was the one who had thought of the need for this new lock-riddance
then i would have done it as follows:
- have a devices xmit_lock as an alias to this other lock in case of
NETIF_F_LLTX 
Then you wouldnt have to touch this code. Infact if it is not too late
why not do it like that?

To add to all this, theres well known semantics of what the return code
means:

-> 0 means the packet was swallowed by driver.
-> 1 means packet was not swallowed.

I dont know why you would need to introduce a new return code. 
All the device is saying is "sorry, I am busy, come back later". Infact
in the pre-softnet days the flag was called precisely "tbusy".
Now, it would make a lot of sense to introduce new return code if you
actually have plans to use it. You probably do but havent stated it. Do
you have plans to use that return code?

Does that explain my unhappiness? ;-> Does that make you happy? ;->
Now i need to refill my coffee.

cheers,
jamal
