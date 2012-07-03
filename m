From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: AF_BUS socket address family
Date: Tue, 03 Jul 2012 11:18:42 -0600
Message-ID: <4FF32972.6020604@genband.com>
References: <4FF1BBD5.8080804@collabora.co.uk> <4FF32352.5040800@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	vincent.sanders@collabora.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FF32352.5040800@genband.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/03/2012 10:52 AM, Chris Friesen wrote:

> To be fair, since it was implemented as a separate protocol family the
> maintenance burden actually hasn't been large--it's been fairly simple
> to port between versions. Also, we do embedded telecom stuff and don't
> jump kernel versions all that often. (It's a big headache, requires
> coordinating between multiple vendors, etc.)
>
> In our case we typically send small (100-200 byte) messages to a
> smallish (1-10) number of listeners, though there are exceptions of
> course. Back before I started the original implementation used a
> userspace daemon, but it had a number of issues. Originally I was
> focussed on the performance gains but I must admit that since then other
> factors have made that less of an issue.

I should point out that some of the other factors that have been 
discussed for AF_BUS also hold true for our implementation:

--strict ordering
--reliable (in our case, if the sender has space in the tx buffer then 
messages get to all recipients with buffer space, there are kernel logs 
if recipients don't have space)

Also, the fact that it's in the kernel rather than a userspace daemon 
reduces priority inversion type issues.  Presumably this would apply to 
an IP-multicast based solution as well.

One problem that I ran into back when I was experimenting with this 
stuff was trying to isolate host-local IP multicast from the rest of the 
network.  It would be suboptimal to need to set up filtering and such 
before being able to use the communication protocol.

Chris
