From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [PATCH,RFC] pktgen sleeping/timing rework
Date: Sat, 11 Dec 2004 00:07:33 +0100
Message-ID: <16826.11317.848178.621626@robur.slu.se>
References: <20041210222058.GA5984@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@data.slu.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041210222058.GA5984@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Lennert Buytenhek writes:
 > 
 > Below is a patch against your latest pktgen devel version which does
 > the following:
 > - Remove usage of get_cycles(), mhz calibration, pg_cycles_per_*,
 >   getRelativeCur[UM]s(), and everything related to reading the CPU
 >   cycle counter directly.  For one, it can't work correctly on
 >   machines that can change clock frequency on the fly 

 Yeep it's for fixed frequency. If it can be done for variable frequency
 w/o to much pain it's fine. Haven't even thought this thought.

 > - Fix up handling of inter-packet gap.  There was some code for
 >   enforcing a certain IPG, but the actual (CPU) cost of the sending
 >   of the packet was not substracted from that, so the effective IPG
 >   ended up being IPG+random_overhead.  This now works somewhat better

 Currently ipg is just a delay to hard_xmit and left to tester to tune.
 

 > - When ipg is set close to the HW limit, behavior becomes a bit wonky.
 >   On my EPIA board I can generate ~110kpps when I set ipg=0, but when I
 >   set ipg=10000 (which would give 100kpps), I only get ~85kps.
 > - We should rename 'ipg' to something different since in our case it
 >   never was and never will be the same as what the ethernet folks mean
 >   with it.
 > 
 > Comments welcome.

 Let me play with it. Hopefully in the beginning of the week.

						--ro
