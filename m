From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH 2/2] NET: Accurate packet scheduling for ATM/ADSL
 (userspace)
Date: Mon, 19 Jun 2006 21:31:22 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0606192048270.31662@ask.diku.dk>
References: <1150278040.26181.37.camel@localhost.localdomain>
 <1150282625.3490.23.camel@localhost.localdomain>  <1150332449.8605.40.camel@ras.pc.brisbane.lube>
 <1150376591.5116.36.camel@jzny2>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Russell Stuart <russell-tcatm@stuart.id.au>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Stephen Hemminger <shemminger@osdl.org>,
	netdev@vger.kernel.org, lartc@mailman.ds9a.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:24039 "EHLO mgw1.diku.dk")
	by vger.kernel.org with ESMTP id S964857AbWFSTbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2006 15:31:25 -0400
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1150376591.5116.36.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Thu, 15 Jun 2006, jamal wrote:

> On Thu, 2006-15-06 at 10:47 +1000, Russell Stuart wrote:
>> On Wed, 2006-06-14 at 11:57 +0100, Alan Cox wrote:
>>> The other problem I see with this code is it is very tightly tied to ATM
>>> cell sizes, not to solving the generic question of packetisation.
>>
>> Others have made this point also.  I can't speak for Jesper,
>> but I did consider making it generic.

I also have considered to make it generic, but choose to make my patch as 
non-intrusive as possible to the kernel (and try to handle as much in 
userspace as possible).

Actually I do think that the kernel patch part is very generic.
The patch simply allow us to align the rate table/array.

With the kernel patch in place, we can work on the userspace TC program to 
support more and more types of exotic link layer modeling.


>> The issue was that
>> doing so would add more code, but I don't personally know
>> of any real world situation that would use the generic
>> solution.  I didn't fancy the thought of arguing on these
>> lists for code that no one would actually use.

;-)


>> If someone could put up their hand and say "Hey, I need
>> this," then expanding the patch to accommodate them would
>> be a pleasure.  I like generic code too.
>>
>
> It is probably doable by just looking at netdevice->type and figuring
> the link layer technology. Totally in user space and building the
> compensated for tables there before telling the kernel (advantage is no
> kernel changes and therefore it would work with older kernels as well).

I think you have got the setup all wrong.

The linux middlebox/router has two ethernet interfaces, one of the 
ethernet interfaces is connected to the ADSL modem.  Thus, the linux 
ethernet card cannot determine that it is connected to an ADSL line.


The patch is the solution to the classical problem people 
have when tryng to configure traffic control on an ADSL link?

Q: The packet scheduling does not work all the time?
A: Try to decrease to bandwidth.

The issue here is, that ATM does not have fixed overhead (due to alignment 
and padding).  This means that a fixed reduction of the bandwidth is not 
the solution.  We could reduce the bandwidth to the worst-case overhead, 
which is 62%, I do not think that is a good solution...

With the patch, you can now simply configure HTB to use the rate that was 
specified by the ISP.

Please read chapter 6 ("Achieving Queue Control") page 55-65, where I 
demonstrate that the naive approach of reducing bandwidth does not work, 
when the packet distribution change on the link.

  http://www.adsl-optimizer.dk/thesis/

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
