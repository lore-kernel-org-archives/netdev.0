From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: sky2 problem on powerpc
Date: Wed, 06 Sep 2006 07:11:05 +1000
Message-ID: <1157490665.22705.128.camel@localhost.localdomain>
References: <1157347462.22705.16.camel@localhost.localdomain>
	 <1157354470.22705.26.camel@localhost.localdomain>
	 <1157355748.22705.32.camel@localhost.localdomain>
	 <20060904204148.6f9749b3@localhost.localdomain>
	 <1157428072.22705.70.camel@localhost.localdomain>
	 <20060904211531.307bbd7f@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:60350 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S1422654AbWIEVLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2006 17:11:16 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060904211531.307bbd7f@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-09-04 at 21:15 -0700, Stephen Hemminger wrote:
> On Tue, 05 Sep 2006 13:47:52 +1000
> Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> 
> > 
> > > It may not need any swapping, it is hard to tell what the hardware
> > > will do without experimentation.
> > 
> > Yes... did you have a chance to test the vlan stuff on LE machines
> > (x86) ? did it work with the BE swapping you were doing ? I've
> > purposedly removed in my patches the hardware side swapping of the
> > descriptors, as I explained, thus making the hardware react the same on
> > ppc and x86. Thus we need the exact same swapping macros on both
> > platforms).
> 
> 
> Last time I checked it worked.  Private cable simulating VLAN
> from other Linux card.

Ok, so we should probably switch back the vlan bits to BE swapping
macros... 

However, we then have an inconsistency with that bit:

#ifdef SKY2_VLAN_TAG_USED
                case OP_RXVLAN:
                        sky2->rx_tag = length;
                        break;

                case OP_RXCHKSVLAN:
                        sky2->rx_tag = length;
                        /* fall through */
#endif

in sky2_status_intr()

Where we read the lenght field directly without swapping (on the non
patched driver, on the patched driver, lenght will have gone through an
LE swap). That is, if you take the standpoint of a LE machine, you will
read that value as a little endian value while elsewhere, we manipulate
sky2->rx_tag as a BE value... (this is even without my patch)

Ben.


