From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: BUG: soft lockup detected on CPU#0!  (2.6.18.2 plus hacks)
Date: Fri, 5 Jan 2007 14:55:05 +0100
Message-ID: <20070105135504.GB3764@ff.dom.local>
References: <OF02F7C182.A05F7E5A-ON88257259.001B0EFA-88257259.001E96CF@us.ibm.com> <E1H2M3X-0001HE-00@gondolin.me.apana.org.au> <20070104080351.GA1740@ff.dom.local> <20070104082930.GB7006@gondor.apana.org.au> <20070104085014.GA2500@ff.dom.local> <20070104102707.GA7662@gondor.apana.org.au> <20070104110435.GA3175@ff.dom.local> <459D339D.7010603@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert.xu@redhat.com>,
	David Stevens <dlstevens@us.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:43326 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161097AbXAENxY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jan 2007 08:53:24 -0500
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <459D339D.7010603@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 04, 2007 at 09:04:29AM -0800, Ben Greear wrote:
> Jarek Poplawski wrote:
> >On Thu, Jan 04, 2007 at 09:27:07PM +1100, Herbert Xu wrote:
> >  
> >>On Thu, Jan 04, 2007 at 09:50:14AM +0100, Jarek Poplawski wrote:
> >>    
> >>>Could you explain? I can see some inet_rtm_newaddr
> >>>interrupted. For me it could be e.g.:
> >>>
> >>>after
> >>>vconfig add eth0 9
> >>>
> >>>ip addr add dev eth0.9 ...
> >>>      
> >>Whether eth0.9 is up or not does not affect this at all.  The spin
> >>locks are initialised (and used) when the first IPv4 address is added,
> >>not when the device comes up.
> >>    
> >
> >I understand this. I consider IFF_UP as a sign all 
> >initialisations (open functions including) are
> >completed and there is permission for working (so
> >logically, if I would do eth0.9 down all traffic
> >should be stopped, what probably isn't true now).
> >  
> It is certainly valid for an interface to be IF_UP, but have no IP 
> address.  My application
> does bring the network device up before it assigns the IP, for instance.

Yes, but I think in any case it isn't races safe
now with vlans. I thought more about the reverse
situation where skb->dev !IFF_UP could be
unnecessarily processed. But the same should be
valid according to the rest of initializations
which are done during address assigning. 

> There may be other issues with IF_UP, but that could be handled with a 
> different
> investigation.  If you have a particular test case that fails with 
> 802.1Q VLANs, then
> I will be happy to work on it...

Sorry, I even didn't use this yet... 

Wish you sunny weekend,

Jarek P.
