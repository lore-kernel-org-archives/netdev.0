From: greg chesson <greg@atheros.com>
Subject: Re: [RFC] acx100 inclusion in mainline; generic 802.11 stack
Date: Wed, 08 Sep 2004 09:02:59 -0700
Sender: acx100-devel-admin@lists.sourceforge.net
Message-ID: <413F2D33.1000508@atheros.com>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua>	 <757AB580-0030-11D9-9224-000A95AD0668@errno.com>	 <20040906182328.08faf843.davem@davemloft.net>	 <200409062132.49356.sam@errno.com> <413DE9ED.30300@atheros.com>	 <20040907101027.7547e591.davem@davemloft.net> <1094628909.1097.145.camel@jzny.localdomain>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,  sam@errno.com,
 vda@port.imtp.ilyichevsk.odessa.ua,  jgarzik@pobox.com,
 netdev@oss.sgi.com,  acx100-devel@lists.sourceforge.net,
 jt@bougret.hpl.hp.com,  jkmaline@cc.hut.fi,  prism54-devel@prism54.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: hadi@cyberus.ca
In-Reply-To: <1094628909.1097.145.camel@jzny.localdomain>
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

You guys are too serious and, I believe, missed the real points.

1.  There is a need in the OS for a "service" to convert between
       .11 and .3 packet formats.   It should be designed for 
hw-independence.
      Everyone sees the same potential for unification
       of wireless drivers.

2.  It's harder to do than it first appears because the complete
      transformation from .3 to .11 cannot be done in isolation
      from the driver(s) and there are monkey wrenches that get
      tossed in from crypto, interaction between crypto and fragementation,
      power-save, observing txoplimits, and other things that tend
      to cross architecture lines that would otherwise be nice and clean.

3.  I personally don't have religion about whether a service
      that transforms headers is implemented as a stack or implemented
      as a side call.   I think that a variety of factors are worth 
considering.
      In this particular case (header transformation), I believe a side call
      "helper function" is appropriate and has less overhead than the full
      protocol stack mechanism.   But it's pointless to argue about it 
without
      measurements.

4.  David's skeleton code is quite interesting and a good start.
       You won't know its usefulness until someone tries to implement
      a real driver.

g



jamal wrote:
> On Tue, 2004-09-07 at 13:10, David S. Miller wrote:
> 
>>On Tue, 07 Sep 2004 10:03:41 -0700
>>greg chesson <greg@atheros.com> wrote:
>>
>>
>>>What about eth_type_trans()?
>>
>>It determines the protocol type from the ethernet header
>>fields.  It is a simple shorthand header field fetcher,
>>not a protocol stack.
>>
>>You would need a eth80211_type_trans() for wireless
>>drivers too, and surprise surprise my skeleton 802.11
>>stack code in fact does exactly this.
> 
> 
> Or as Andi has been suggesting for sometime, not invoke it all ;->
> This is possible if the DMA descriptor already has all the info
> needed (quiet a few modern hardware can be programmed to do this).
> .. er, at the driver level. So this is not "a gross input packet
> hooked eater thing that's an ugly wart bolted onto the
> side of the driver API.";->
> 
> cheers,
> jamal
> 
> 
> 



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
