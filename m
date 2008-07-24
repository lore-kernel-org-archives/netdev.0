From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC][PATCH 1/3] net: per skb control messages
Date: Fri, 25 Jul 2008 02:14:11 +0300
Message-ID: <200807250214.11298.opurdila@ixiacom.com>
References: <200807250049.46939.opurdila@ixiacom.com> <200807250112.03379.opurdila@ixiacom.com> <20080724.151733.215864673.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:4832 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755862AbYGXXQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 19:16:38 -0400
In-Reply-To: <20080724.151733.215864673.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 25 July 2008, David Miller wrote:
> From: Octavian Purdila <opurdila@ixiacom.com>
> Date: Fri, 25 Jul 2008 01:12:03 +0300
>
> > On Friday 25 July 2008, David Miller wrote:
> > > We have a timestamp in the SKB already, why don't you simply override
> > > it when your feature is enable and set a single flag bit that
> > > indicates you used a HW timestamp to set that timestamp?
> >
> > I thought of something similar, but I am not sure if I can to so, as it
> > seems that the skb->tstamp requires current gettimeofday semantics at
> > least in netfilter's ipt_time module.
>
> Can your timestamp format at least be converted to
> gettimeofday() format?
>
> I thought we had a ton of accessor functions that code uses to access
> the timestamp?  You should be able to do your translation in those
> routines.

Sure but the problem is that the NIC hw timestamp is not synced with the CPU 
time. In that case I think that the netfilter rules which are looking at the 
timestamp will be messed up.

[ 
A bit of general context about this annoying hw timestamp thing I keep 
bringing up  here:) 

I know that this is a very specific thing and there is probably not a clean 
solution to this and we will probably have to go with an in internal patch 
approach. 

But the thing is that we accumulated a lot such internal patches to the point 
that makes it very hard to upgrade and track a recent Linux version. And I 
feel that we need to stop adding new stuff in this pile, otherwise we will 
not be able to keep up.

Thus my fixation with this very specific and not so significant thing in the 
great Linux ecosystem. Probably I just chosen the wrong patch to battle. 
]

Thanks,
tavi
