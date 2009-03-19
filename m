From: David Miller <davem@davemloft.net>
Subject: Re: iproute2: prints bogus hoplimit
Date: Wed, 18 Mar 2009 17:51:09 -0700 (PDT)
Message-ID: <20090318.175109.14058201.davem@davemloft.net>
References: <alpine.LSU.2.00.0902241125020.329@fbirervta.pbzchgretzou.qr>
	<20090318151216.60cd0363@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jengelh@medozas.de, stephen.hemminger@vyatta.com,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58980
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754846AbZCSAvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 20:51:22 -0400
In-Reply-To: <20090318151216.60cd0363@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 18 Mar 2009 15:12:16 -0700

> On Tue, 24 Feb 2009 11:27:52 +0100 (CET)
> Jan Engelhardt <jengelh@medozas.de> wrote:
> 
> > 
> > $ ip -6 r
> > fc00::/7 dev rtl0  proto kernel  metric 256  mtu 1500 advmss 1440 
> > hoplimit 4294967295
> > 
> > Most likely, "hoplimit -1" would be the right number, though I am not 
> > sure if simply changing %u by %d is a correct thing to do, since it 
> > would affect all fields.
 ...
> > diff --git a/ip/iproute.c b/ip/iproute.c
> > index 6a2ea05..91a8cc0 100644
> > --- a/ip/iproute.c
> > +++ b/ip/iproute.c
> > @@ -507,7 +507,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
> >  
> >  			if (i != RTAX_RTT && i != RTAX_RTTVAR &&
> >  			    i != RTAX_RTO_MIN)
> > -				fprintf(fp, " %u", *(unsigned*)RTA_DATA(mxrta[i]));
> > +				fprintf(fp, " %d", *(unsigned*)RTA_DATA(mxrta[i]));
> >  			else {
> >  				unsigned long long val = *(unsigned*)RTA_DATA(mxrta[i]);
> >  
> 
> No fix the kernel please.

I don't know what you mean by this Stephen.  Why don't you take
a look at when and why the kernel uses '-1'?

"-1" is the hoplimit the kernel uses in the dst metric to mean
"use the default".

So this iproute patch is absolutely correct, or alternatively, iproute
can print "default" when it sees '-1'.

