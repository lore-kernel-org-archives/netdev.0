From: Ben Greear <greearb@candelatech.com>
Subject: Re: [Bug 4177] New: Please consider adding possibility to have	multiple
 PPPoE sessions with different MAC addresses
Date: Mon, 07 Feb 2005 08:49:46 -0800
Message-ID: <42079C2A.4010006@candelatech.com>
References: <200502061207.j16C7UOB009882@fire-1.osdl.org>	 <420683CB.2010205@conectiva.com.br> <1107793112.15984.238.camel@brick.watson.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
        Networking Team <netdev@oss.sgi.com>, mh+kernel-bugzilla@zugschlus.de
To: Michal Ostrowski <mostrows@speakeasy.net>
In-Reply-To: <1107793112.15984.238.camel@brick.watson.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michal Ostrowski wrote:
> I'm very hesitant to put something like this into the PPPoE code, though
> I could if the demand for it is strong enough. I think the proper
> solution is something that should be implemented primarily in the
> generic networking code.  
> 
> The right approach IMO is to do something similar to IP-aliasing; that
> is to permit an alternate instance of the interface to exist with the
> desired MAC address.
> 
> Currently one can use IP-aliasing to do this at the IP level:
> 
> ifconfig eth0    10.10.10.10 up ....
> ifconfig eth0:1  10.10.10.11 up ....
> 
> Likewise, I'd propose ethernet aliasing
> 
> ifconfig eth0 10.10.10.10 up ....   #Use native address
> ifconfig eth0.A hw ether AA:BB:CC:DD:EE:FF  # Create mac-addr alias dev
> 
> 
> Given something like this, PPPoE over eth0.A would just work using the
> MAC address bound to eth0.A.
> 
> The virtues of such a scheme are that it eliminates the need for
> management code in PPPoE as PPPoE is not responsible for implementing
> the binding of the new MAC address.  The PPPoE code should not be in the
> business of putting devices into promiscuous mode, and then tracking
> whether or not they should be taken out of promiscuous mode. 
> 
> This scheme also allows for the possibility that hardware devices
> themselves may support multiple MAC addresses (if they can be programmed
> to do so).

I have a MAC-VLAN patch that already does this.  It's based on work
by Alex Zeffertt, but has been considerably hacked by me so he no
should get no blame for what I have done :)  MAC-VLANs allow one to create
a virtual ethernet interface and packets are routed to it based on the
source (or destination) MAC address.  To user-space, each MAC-VLAN
looks just like an ethernet interface.

It is all glommed into my big networking patch, but if there is serious
interest, then I will split it out.  It does require a hook near the bridging
hook in dev.c, and in the past, DaveM has not liked me putting hooks there, so
he may not accept this anyway...

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
