From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: [Fwd: [E1000] NAPI re-insertion w/ changes]
Date: Tue, 1 Apr 2003 16:13:31 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E010107D325@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <netdev-bounce@oss.sgi.com>
To: Jason Lunz <lunz@reflexsecurity.com>, Jeff Garzik <jgarzik@pobox.com>,
   Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com
content-class: urn:content-classes:message
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> The graphs are up now. The best driver measured so far is 
> Robert's change to reinstate irq-disable-on-poll + 
> reduce-pci-traffic, with XsumRX turned off. I'm currently 
> measuring to see if it still has an advantage with 
> checksumming turned on.

Very good.  Jeff has the patch for -k2 which should be equivalent to
-ro2.

Robert, please post your -ro3 changes - I can't find them.

BTW, the things that changed from 4.4.19-k3 to 5.0.43-k2 that may
account for the improvements are:

o eliminate the modulus operator for ring index wrapping
(anton@samba.org)
o single read of ICR (Interrupt Cause Register) in e1000_intr
o dynamic ITR (Interrupt Throttle Rate) algorithm for 82545/6

Sum of many second-order improvements add up.  We'll take all we can
find.

> Scott, your bugfix of removing the while() from e1000_clean() 
> puts the original 5.0.43-k1 driver from 2.5.66 back in the 
> running. It no longer suffers from watchdog timeouts, and 
> doesn't degrade under high load.  It still scores lowest, 
> though.  I've seen that the max-pps-ceiling visible in these 
> graphs is highly sensitive to CPU load, so I'd guess that the 
> sf1 test lost solely because of the overhead of still running 
> the irq handler once in a while.  

Ok, that settles that.  Thanks for re-running the tests.

I'm pretty happy with this NAPI code for e1000.  Next step is to get
some more generic QA testing with NAPI and then port back to 2.4.x.

-scott
