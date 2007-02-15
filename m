From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: sky2 bonding problem, 802.3ad
Date: Thu, 15 Feb 2007 16:43:03 -0500
Message-ID: <20070215214303.GC10713@hmsreliant.homelinux.net>
References: <871wkruu6p.fsf@kruemel.my-eitzenberger.de> <200702152013.l1FKDE22017473@death.nxdomain.ibm.com> <87fy97t9ez.fsf@kruemel.my-eitzenberger.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>, shemminger@linux-foundation.org,
	sk-drivers@lists.linux-foundation.org, netdev@vger.kernel.org
To: Holger Eitzenberger <holger@my-eitzenberger.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4609 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161410AbXBOVnr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Feb 2007 16:43:47 -0500
Content-Disposition: inline
In-Reply-To: <87fy97t9ez.fsf@kruemel.my-eitzenberger.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 15, 2007 at 10:09:40PM +0100, Holger Eitzenberger wrote:
> Jay Vosburgh <fubar@us.ibm.com> writes:
> 
> > 	I'm unfamiliar with your particular switch, but usually this
> > kind of problem with bonding 802.3ad is in the switch interaction.  The
> > switches I have (Cisco) require that 802.3ad mode be explicitly enabled
> > on whichever ports it is desired on, so it may be worthwhile to check
> > your switch and make sure that it really is configured for 802.3ad on
> > the sky2 ports.
> 
> I am currently using port 1&2 and port 9&10 for bonding and have
> configured all four ports for the same aggregator ID 1, LCAP enabled.
> I also switched ports, that is, I changed host1 from using port 1&2 to
> use port 9&10 and vice versa.  Note that I also used sk98lin which
> worked in my setup also.  Do you still think it is a misconfigured
> switch?
> 
> > 	If the switch is configured, you may want to also check to see
> > if it has counters for LACPDUs sent and received.  If the switch is not
> > sending and receiving LACPDUs on the appropriate ports, then it's more
> > likely to be a communications problem somewhere (vs. an 802.3ad
> > negotiation problem).
> 
> I will check tomorrow morning whether I see the LACPDUs in the log and
> report.
> 
> Any more tests which may be helpfull?
> 
If I had to guess I'd say that sky2 wasn't setting its multicast list properly,
or the bonding driver wasn't telling it too.  IIRC LACPDU's are received on a
reserved multicast MAC address, which the hardware needs to be told to receive.
If the bonding driver isn't receving those frames (which I think you should be
able to tell by looking at the sky2 rx_multicast stat with ethtool.  If the
value isn't going up then you aren't getting LACPDU frames). The hardware should
have that the lacpdu multicast address added during the enslaving process (via
bond enslave).  I'd start instrumenting that part of the driver, as well as
sky2.c's set_multicast_list method, to see if anything is going awry.

Regards
Neil

> Thanks.  /holger
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
