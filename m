From: Michal Ostrowski <mostrows@speakeasy.net>
Subject: Re: [Bug 4177] New: Please consider adding possibility to have
	multiple PPPoE sessions with different MAC addresses
Date: Mon, 07 Feb 2005 11:18:32 -0500
Message-ID: <1107793112.15984.238.camel@brick.watson.ibm.com>
References: <200502061207.j16C7UOB009882@fire-1.osdl.org>
	 <420683CB.2010205@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Networking Team <netdev@oss.sgi.com>, mh+kernel-bugzilla@zugschlus.de
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <420683CB.2010205@conectiva.com.br>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'm very hesitant to put something like this into the PPPoE code, though
I could if the demand for it is strong enough. I think the proper
solution is something that should be implemented primarily in the
generic networking code.  

The right approach IMO is to do something similar to IP-aliasing; that
is to permit an alternate instance of the interface to exist with the
desired MAC address.

Currently one can use IP-aliasing to do this at the IP level:

ifconfig eth0    10.10.10.10 up ....
ifconfig eth0:1  10.10.10.11 up ....

Likewise, I'd propose ethernet aliasing

ifconfig eth0 10.10.10.10 up ....   #Use native address
ifconfig eth0.A hw ether AA:BB:CC:DD:EE:FF  # Create mac-addr alias dev


Given something like this, PPPoE over eth0.A would just work using the
MAC address bound to eth0.A.

The virtues of such a scheme are that it eliminates the need for
management code in PPPoE as PPPoE is not responsible for implementing
the binding of the new MAC address.  The PPPoE code should not be in the
business of putting devices into promiscuous mode, and then tracking
whether or not they should be taken out of promiscuous mode. 

This scheme also allows for the possibility that hardware devices
themselves may support multiple MAC addresses (if they can be programmed
to do so).

-- 
Michal Ostrowski <mostrows@speakeasy.net>


On Sun, 2005-02-06 at 18:53 -0200, Arnaldo Carvalho de Melo wrote:
> bugme-daemon@osdl.org escreveu:
> > http://bugme.osdl.org/show_bug.cgi?id=4177
> > 
> >            Summary: Please consider adding possibility to have multiple
> >                     PPPoE sessions with different MAC addresses
> >     Kernel Version: 2.6.current, 2.4.current
> >             Status: NEW
> >           Severity: low
> >              Owner: acme@conectiva.com.br
> >          Submitter: mh+kernel-bugzilla@zugschlus.de
> > 
> > 
> > This wishlist item is mostly relevant to German users. In 
> > Germany, Deutsche Telekom has a near monopoly regarding DSL 
> > connections to residential homes. They are, however, required, to 
> > resell their network to other ISPs which has led to a rather 
> > interesting combination of Internet tariffs and feature sets available 
> > via Deutsche Telekom T-DSL connections. 
> >  
> > Technical Basis for the T-DSL customer interface is PPPoE over a 
> > bridged ATM session, so it is technically possible to have multiple 
> > PPPoE sessions on the same line, allowing concurrent use of more than 
> > a single ISP which might be interesting with special interest services 
> > like streaming, fixed IP address and/or flat rate. 
> >  
> > However, Deutsche Telekom technically forbids multiple PPPoE sessions 
> > originating from a single MAC address, so one needs multiple network 
> > interfaces to originate the PPPoE sessions from. 
> >  
> > Sven Geggus has a patch against rp-pppoed, which allows to fake the 
> > sending MAC address for additional PPPoE sessions, circumventing the 
> > artificially introduced limitation of the T-DSL connection. The patch 
> > is available on http://geggus.net/sven/rp-pppoe-fakemac.diff 
> >  
> > Please consider adding that possibility to the kernel PPPoE code as well. 
> >  
> > Greetings 
> > Marc
> > 
> > ------- You are receiving this mail because: -------
> > You are the assignee for the bug, or are watching the assignee.
> > 
> > 
> 
-- 
Michal Ostrowski <mostrows@speakeasy.net>
