From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: BUG: soft lockup detected on CPU#0!  (2.6.18.2 plus hacks)
Date: Thu, 4 Jan 2007 09:50:14 +0100
Message-ID: <20070104085014.GA2500@ff.dom.local>
References: <OF02F7C182.A05F7E5A-ON88257259.001B0EFA-88257259.001E96CF@us.ibm.com> <E1H2M3X-0001HE-00@gondolin.me.apana.org.au> <20070104080351.GA1740@ff.dom.local> <20070104082930.GB7006@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Stevens <dlstevens@us.ibm.com>, greearb@candelatech.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:39470 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932328AbXADIse (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jan 2007 03:48:34 -0500
To: Herbert Xu <herbert.xu@redhat.com>
Content-Disposition: inline
In-Reply-To: <20070104082930.GB7006@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 04, 2007 at 07:29:30PM +1100, Herbert Xu wrote:
> On Thu, Jan 04, 2007 at 09:03:51AM +0100, Jarek Poplawski wrote:
> > 
> > I doubt this is the right solution. It certainly
> > could fix this particular situation but my main
> > point was packets shouldn't get into kernel
> > receive queues with skb->dev not IFF_UP.
> 
> I think you misunderstood.  The device certainly is IFF_UP.  What
> happens is that the multicast spin locks are set up too late:

Could you explain? I can see some inet_rtm_newaddr
interrupted. For me it could be e.g.:

after
vconfig add eth0 9

ip addr add dev eth0.9 ...

before
ip link set dev eth0.9 up

Jarek P.
