From: Michal Ostrowski <mostrows@watson.ibm.com>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: 25 Jun 2003 14:00:55 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1056564055.1944.2041.camel@brick.watson.ibm.com>
References: <20030625072602.529AF2C0B9@lists.samba.org>
	 <1056547262.1945.1436.camel@brick.watson.ibm.com>
	 <20030625091531.5ebed618.shemminger@osdl.org>
	 <20030625122128.V84526@shell.cyberus.ca>
	 <20030625093902.7431efc3.shemminger@osdl.org>
	 <20030625125518.N84526@shell.cyberus.ca>
	 <20030625104001.476ee314.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi <hadi@shell.cyberus.ca>, rusty@rustcorp.com.au,
   "David S. Miller" <davem@redhat.com>, Paul MacKerras <paulus@samba.org>,
   netdev@oss.sgi.com, fcusack@samba.org, carlson@workingcode.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030625104001.476ee314.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2003-06-25 at 13:40, Stephen Hemminger wrote:

> For PPPoE, the session management needs to be in kernel space, with the policy
> in user space.  What if the kernel, initialized the session when it saw
> the discovery and notified the pppd,  session would not be established
> until ppd accepted the connection.  This would be more like a socket
> protocol without auto-accept like TCP. Any data for the session would
> then stay queued until it was accepted or rejected.
> 

Regardless of the solution take for the session-initiation race, any
solution would fall apart if SMP softIRQ's can reorder packets (that is
it would result in dropped packets).  Only once there is a solution for
this reordering problem does it make sense to consider the options for
handling this race.

PPPoE also doesn't exactly cleanly fit nicely into the standard
bind()/listen()/accept()/connect() mould.  I've been convinced that
negotiation/discovery belongs in pppd and so would like to avoid adding
connection detection logic into the kernel.

Finally, please keep in mind that with PPPoE when we do hit this problem
the effect is that PPP session establishment takes a bit longer since we
have to wait for an LCP timeout and retransmit.   I am much more curious
about how other protocols may be affected by packet reordering.

-- 
Michal Ostrowski <mostrows@watson.ibm.com>
