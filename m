From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: Thu, 26 Jun 2003 08:17:38 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16122.8066.928895.202985@nanango.paulus.ozlabs.org>
References: <20030625072602.529AF2C0B9@lists.samba.org>
	<1056547262.1945.1436.camel@brick.watson.ibm.com>
	<1056548544.1944.1488.camel@brick.watson.ibm.com>
	<20030625114243.F84526@shell.cyberus.ca>
	<1056562079.1944.1961.camel@brick.watson.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi <hadi@shell.cyberus.ca>, Rusty Russell <rusty@rustcorp.com.au>,
   "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
   "David F. Skoll" <dfs@roaringpenguin.com>,
   James Carlson <carlson@workingcode.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Michal Ostrowski <mostrows@watson.ibm.com>
In-Reply-To: <1056562079.1944.1961.camel@brick.watson.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michal Ostrowski writes:

> Paul:  you made an assertion to me in an eariler e-mail that you were
> concerned about packet ordering for the sake of vj and compression. 
> IIRC the PPPoE spec prohibits compression, probably for this very
> reason. Is there any other reason we'd be worried about re-ordering in
> the PPP data stream?

Reordering would stop you doing multilink, for instance.  Generally,
PPP protocols assume ordering where it is helpful since most
point-to-point links don't reorder packets.  IMO the PPPoE protocol
itself should have included a sequence number, but we can't change
what's deployed.

James might be able to comment better than me on what will happen if
packets get reordered during the negotiation phase of a PPP
connection.  I think the worst is that some packets will have to be
retransmitted and thus the negotiation will take several seconds
longer than it needs to.

Paul.
