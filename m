From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: I/O operations
Date: Thu, 21 Nov 2002 13:40:34 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15836.54338.135589.998015@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


While hacking with e1000...

For e1000 reading the interrupt control (ICR) register also acks it. 
I guess the idea is to save I/O operations which are very slow in 
comparison to CPU speed. So reading and acking is done atomically 
in just one operation. 

And it should be possible to extend this to even disable interrupts 
(if ICR nonzero) in the same operation? 

At least for NAPI "type" drivers this seems useful...

1) H/W generates interrupt which "indicates" work.
2) Driver Reads/Acks/Disables-IRQ in one I/O operation and 
   schedules work for softirq.



Any chips capable of this already?

Cheers.
						--ro
