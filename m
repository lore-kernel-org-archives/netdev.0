From: Ben Greear <greearb@candelatech.com>
Subject: Re: gettime: Was (Re: Route cache performance under stress
Date: Wed, 11 Jun 2003 08:57:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EE75164.8030500@candelatech.com>
References: <3EE682B8.8060708@candelatech.com> <20030610.182234.74725315.davem@redhat.com> <3EE68B15.60802@candelatech.com> <20030610.203325.41658167.davem@redhat.com> <20030611065255.L39678@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jamal Hadi <hadi@shell.cyberus.ca>
In-Reply-To: <20030611065255.L39678@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jamal Hadi wrote:
> Ok, time to go into another separate thread ;->
> 
> Sounds like a good idea.
> 
> if (skbneedstimestamp)
> 	do_gettimeofday(&skb->stamp);
> else
> 	defertimestamp()
> 
> For defertimestamp() would it be feasible that you store only the
> jiffies value in the skb then get timeofday later and somehow
> compensate for the difference? Seems very doable to me.
> 
> Question is when do you decide skbneedstimestamp?
> Is it when the device is in promiscous mode or do it in ip or icmp etc?
> 
> cheers,
> jamal

Jiffies is not nearly precise enough.  You need something with
usec precision at least.

If we make a macro to read the value (converting as needed), and just
change all the readers to use that macro, then we don't have to make any
interesting decisions in the networking core.

Ben


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
