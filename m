From: Peter Kjellstroem <cap@nsc.liu.se>
Subject: e1000>5.2.30 unstable with InterruptThrottleRate=0
Date: Fri, 3 Dec 2004 20:02:00 +0100 (CET)
Message-ID: <Pine.LNX.4.44.0412031833150.13794-100000@papput.nsc.liu.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello folks,

Short version: 82547GI with ITR=0 on 2.4.28 (vanilla) and RHEL3u3 has           
problems (traffic grinds to a temporary halt under anything but trivila         
network traffic). kernel prints the following and resets the IF (many           
times):                                                                         
                                                                                
NETDEV WATCHDOG: eth0: transmit timed out           


More verbose version with background:
I have a problem with e1000 being unstable when I run it with 
InterruptThrottleRate=0 (abbreviated ITR in the rest of this e-mail). I 
need to turn ITR off or set it so large that it behaves as off. The reason 
for having to turn it off is that I run MPI-applications (cluster stuff) 
and that happens to be largely latency bound.

Latency with default e1000 is terrible, 250 us, with ITR=0 (where it 
works) the latency drops to 20-25 us.

Enough of background. Up untill now I have allways been able to run with 
ITR=0 and intel gigabit has been very nice. Now, for some combinations of 
driver, chip and ITR setting it all falls apart.


Affected chips (theory, 8254X, X>1 or anything faster then PCI33):
82547GI, 82546 (said to be affected, not verified by me)

Unaffected chips:
82541 (rock solid no matter what driver or ITR)


Linux-2.4.26 vanilla (smp, without NAPI with e1000 as module) is ok
(82547, ITR=0, rock solid)

Linux-2.4.28 vanilla (smp, without NAPI with e1000 as module) is BAD
(82547 needs ITR<20000 for resonable stability)

Linux-2.4.28 with e1000 from 2.4.26 but otherwise exactly as above is ok
rock solid!!!

Linux-2.4.21-20smp RHEL3 update 3 is BAD
(known stable with default ITR (1?) but probably ok for <20000)

Conclusions: something happened above e1000 version 5.2.30 (as in 
linux-2.4.26), RHEL has 5.2.52 and 2.4.28 has 5.4.11.


Some more discussions on this subject has taken place on another list, see 
following thread if interested:
 http://lists.us.dell.com/pipermail/linux-poweredge/2004-November/023061.html


Best Regards,
 Peter

-- 
------------------------------------------------------------
  Peter Kjellstroem              | E-mail: cap@nsc.liu.se
  National Supercomputer Centre  |
  Sweden                         | http://www.nsc.liu.se
