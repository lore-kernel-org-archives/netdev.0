From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: Wed, 25 Jun 2003 09:15:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030625091531.5ebed618.shemminger@osdl.org>
References: <20030625072602.529AF2C0B9@lists.samba.org>
	<1056547262.1945.1436.camel@brick.watson.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, davem@redhat.com, paulus@samba.org,
   netdev@oss.sgi.com, fcusack@samba.org, dfs@roaringpenguin.com,
   carlson@workingcode.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michal Ostrowski <mostrows@watson.ibm.com>
In-Reply-To: <1056547262.1945.1436.camel@brick.watson.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 25 Jun 2003 09:21:02 -0400
Michal Ostrowski <mostrows@watson.ibm.com> wrote:

> First some background for those new to this discussion (I was going post
> the original discussion that strted this to this list, but the summary
> here should get everyone up to speed).
> 
> A user has observed a race condition where the last packet of PPPoE
> discovery arrives just before the first payload packet.  The discovery
> packet carries the session id and pppd needs to take this session id and
> create a PPPoE socket which will then pick up all packets matching the
> given session id.  The race is between the arrival of the first payload
> packet and  pppd's creation of the socket that is to receive PPPoE
> payload.  If the packet wins the race, the payload packet is lost.  This
> problem was noticed only because the ISP in this case configured their
> systems to use a longer, non-standard (but legal) retransmit timeout
> thus causing noticeable delays in PPP negotiation.
> 

Also, you only need the ordering dependency till the session is setup, not
after it is established.  Imagine a large ISP with many PPPoE sessions; it
makes no sense to serialize traffic just for this session establishment case.

In the long run, the right answer probably is to push the session management
out of the daemon and into the kernel.  Today the PPPoE code in the kernel
is only half-brained, it needs pppd to survive.
