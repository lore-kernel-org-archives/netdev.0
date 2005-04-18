From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: NAPI, e100, and system performance problem
Date: Mon, 18 Apr 2005 17:36:08 +0200
Message-ID: <16995.54248.296368.769248@robur.slu.se>
References: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
In-Reply-To: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Brandeburg, Jesse writes:
 > _Summary_
 > As the part owner of the e100 driver, this issue has been nagging at me
 > for a while.  NAPI seems to be able to swamp a system with interrupts
 > and context switches.   In this case the system does not respond to
 > having zero cpu cycles available by polling more, as I figured it would.
 > This was mostly based on observation, but I included some quick data
 > gathering for this mail.

 Hello!

 Well to sort out some things. NAPI address just the balance between 
 irq  and softirq's nothing else, In the balance between userland and 
 sofirq's we pray that sofirq's should behave well. In some cases 
 these are deferred to ksoftirqd to balance softirq/user.

 > With the current e100 driver in NAPI mode the adapter can generate
 > upwards of 36000 interrupts a second from only receiving 77000
 > packets/second (pktgen traffic)

 You have a very fast CPU and slow device. Interrupt ISR handles two 
 packets etc. Same for NAPI/non-NAPI path. Not bad really. Probably
 you had interrupt delay w. non-NAPI so the interrupt rate was a bit
 lower this OK w, NAPI too if you like it. 

 > Is there any way we can configure how soon or often to be polled
 > (called)? For 100Mb speeds at worst we can get about one 64 byte packet
 > every 9us (if I did my math right) and since the processors don't take
 > that long to schedule NAPI, process a packet and handle an interrupt, we
 > just overload the system with interrupts going into and out of napi
 > mode.  In this case I only have one adapter getting scheduled.

 Interrupt delay is the most straight forward... You can play with some
 driver timer. Balance timer and the RX ring size so it does not overflow 
 and register for poll when the timer func have receive packets. You would 
 see no interrupts at all... Could be fun it feel like sub-optimizing. 
 No I think at these levels interrupts are our friends. 

 Cheers.
					--ro
