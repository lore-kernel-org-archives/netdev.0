From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6] update to network emulation QOS scheduler
Date: 07 Jul 2004 14:57:48 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089226667.1027.411.camel@jzny.localdomain>
References: <20040701113312.43cfe6c5@dell_ss3.pdx.osdl.net>
	 <20040702134437.5891e998@dell_ss3.pdx.osdl.net>
	 <1088824432.1043.271.camel@jzny.localdomain>
	 <20040707111055.32ebb25b@dell_ss3.pdx.osdl.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, Catalin BOIE <util@deuroconsult.ro>,
        netdev@oss.sgi.com, lartc@mailman.ds9a.nl
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040707111055.32ebb25b@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I seem to have hit the jackpot - all my emails to netdev are showing
up and on time too.

On Wed, 2004-07-07 at 14:10, Stephen Hemminger wrote:
> Ok, I'll bite how would you do:
> 
> Rate limit packet egress on a ethernet device (eth0) so it looks like a slow DSL link (25 Kbps)
> by not dropping packets but by pacing the data.

Doesnt TBF work? 
rate 25kbit burst 90k should probably do it.  Maybe i misunderstood the
question.

You may be able to avoid dropping but dont think you can guarantee it
simply because you have finite buffers. At some point you will congest
that queue and packets will be dropped; and if you dont limit your queue
buffer size, sooner than later you are bound to hog all the system
memory. 
Having said that, i have never seen a good arguement for why pacing
traffic vs dropping to initiate a slowdown is better than the other.
So in that case, a policer/meter should suffice.

cheers,
jamal
