From: Boris Protopopov <borisp@mc.com>
Subject: Re: bonding vs 802.3ad/Cisco EtherChannel link agregation
Date: Fri, 13 Sep 2002 10:50:11 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D81FB23.EEBD371C@mc.com>
References: <288F9BF66CD9D5118DF400508B68C4460475892C@orsmsx113.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@redhat.com>, linux-net@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, Scott, David, thanks for your replies, 
I agree that it seems that I bonding does not help with a single conection (btw,
is this a single TCP conneciton, or an ordered pair of IP addresses, or an
ordered pair of MAC addresses ?). My question is: why ? 

Scott, I am not sure I understand your analogy. It seems that you suggest that I
cannot saturate GigE with a single hose (a single Netpipe connection, I am
guessing). My experiments, however, indicate that I can - I get ~900Mbits/sec
out of 1000Mbits/sec with 20% CPU utilization when I use a single Netpipe
connection. I am guessing, the ~10% underutilization is caused by the protocol
overheads (headers/trailers). I added another GigE link, bonded it with the
first one, and repeated the experiment. I saw the ethernet frames evenly
distributed between the two links (ifconfig statistics), which, in my opinion,
indicated that a single Netpipe connection was in fact using both links. The CPU
utilization rose a bit, but it was nowhere near even 50%. The memory subsystem
seems to be able to handle over 1000Mbytes/sec, the peripheral bus is 100Mhz
64-bit PCI-X (handles 800Mbytes/sec). So, obviously, there is a bottneck
somewhere, but I don't understand where. I think my CPU/memory/I/O hose is big
enough to fill up two GigE links (~200Mbytes/sec), however, this is not
happening. My question is: why ?

I know why this is happens when I use teaming: because, on each side, one GigE
link is dedicated to sending, and the other one - to receiving (again, I use
ifconfig statistics to see what's happening). Acording to what I was told, this
is because 802.3ad and EtherChannel insist that all GigE frames that belong to a
"conversation" (I was unable to find a technical definition of the
"conversation" so far) are delivered in order. I would like to understand what a
"conversation" is, and why TCP/IP could not handle out-of-order delivery in it's
usual manner. I am guessing, because it would be too slow or would incur too
much CPU overhead. I was wondering if someone knew for sure :)

Thanks again, hope to get more opinions (it seems I am not alone :)),
Boris.


"Feldman, Scott" wrote:
> 
> > Bonding does not help with single stream performance.
> > You have to have multiple apps generating multiple streams
> > of data before you'll realize any improvement.
> > Therefore netpipe is a bad test for what you're doing.
> 
> The analogy that I like is to imagine a culvert under your driveway and you
> want to fill up the ditch on the other side, so you stick your garden hose
> in the culvert.  The rate of water flow is good, but you're just not
> utilizing the volume (bandwidth) of the culvert.  So you stick your
> neighbors garden hose in the culvert.  And so on.  Now the ditch is filling
> up.
> 
> So stick a bunch of garden hoses (streams) into that culvert (gigabit) and
> flood it to the point of saturation, and now measure the efficiency of the
> system (CPU %)  How much CPU is left to do other useful work?  The lower the
> CPU utilization, the higher the efficiency of the system.
> 
> Ok, the analogy is corny, and it doesn't have anything to do with bonding,
> but you'd be surprise how often this question comes up.
> 
> -scott
> -
> To unsubscribe from this list: send the line "unsubscribe linux-net" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
