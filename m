From: jamal <hadi@cyberus.ca>
Subject: Re: [patch 4/10] s390: network driver.
Date: 05 Jan 2005 08:16:51 -0500
Message-ID: <1104931011.1118.134.camel@jzny.localdomain>
References: <OFB7F7E23F.EFB88418-ONC1256F7E.0031769E-C1256F7E.003270AD@de.ibm.com>
	 <1104764710.1048.580.camel@jzny.localdomain>  <41DB26A6.2070008@pobox.com>
	 <1104895169.1117.63.camel@jzny.localdomain>
	 <Pine.LNX.4.61.0501050627050.27046@hibernia.jakma.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
        Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        Tommy Christensen <tommy.christensen@tpack.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Paul Jakma <paul@clubi.ie>
In-Reply-To: <Pine.LNX.4.61.0501050627050.27046@hibernia.jakma.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-01-05 at 01:30, Paul Jakma wrote:
> On Wed, 4 Jan 2005, jamal wrote:
> 
> > Theres possibly people who would want it differently - so for we 
> > havent heard from them. Maybe poll far and wide - or push it in and 
> > wait for them to whine.
> 
> We're whining.
> 
> This policy in the Linux kernel makes using Linux dangerous for 
> certain routing applications (RIP, routing advertisements).
> 
> Name a non-TCP application that *does* want this newish kernel policy 
> and tell me how it breaks without this *new* policy. ;)

Ok, Iam confused - I thought you guys _wanted this_ ;->
The issue is about message obsolency more than it is about reliability.
Without this the scenario you played you played for us before was:

1)=>send a few LSAs from user space, pull cable before they go out
(this will happen if you are sending sufficiently large amounts of
packets i.e network is busy),
2)=>user space gets notified via netlink, device shuts down acces to
DMA, packets queued anyways and you have no ability to say "ooops,sorry
take that packet back"
a)You could do a move to another device at this point.
or
b) dumb app will continue sending

3)=>plug cable back in 2 minutes later, obsolete LSAs sent followed by
any new ones that may follow
....

With the patch, packets in #2 will be dropped. As a matter of fact
within those two minutes, if stopped, it is probable the device watchdog
timer will kick in and flush the DMA but not the scheduler queues above
it (which is where upto a 1000 stale packets could be sitting).

What is it that you dont like now? 

cheers,
jamal
