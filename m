From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch iproute2] vxlan: use 8472 as default dst port
Date: Thu, 16 May 2013 09:02:39 -0700
Message-ID: <20130516090239.06067273@nehalam.linuxnetplumber.net>
References: <1368616270-5775-1-git-send-email-amwang@redhat.com>
	<OFA8084FAB.8443890D-ON85257B6C.003F1FAB-85257B6C.003F65F2@us.ibm.com>
	<20130515095322.275c9b2f@nehalam.linuxnetplumber.net>
	<OFF100C7ED.6500FAB3-ON85257B6C.005DCF7C-85257B6C.005F309B@us.ibm.com>
	<20130515104308.5de3e852@nehalam.linuxnetplumber.net>
	<OF80FDF86D.7A293781-ON85257B6C.0061CCF7-85257B6C.0063F69C@us.ibm.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B723D@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David Stevens" <dlstevens@us.ibm.com>,
	"Cong Wang" <amwang@redhat.com>, <netdev@vger.kernel.org>,
	<netdev-owner@vger.kernel.org>
To: "David Laight" <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35468 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752256Ab3EPQCo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 12:02:44 -0400
Received: by mail-pa0-f44.google.com with SMTP id jh10so2652237pab.31
        for <netdev@vger.kernel.org>; Thu, 16 May 2013 09:02:43 -0700 (PDT)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B723D@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 May 2013 09:24:47 +0100
"David Laight" <David.Laight@ACULAB.COM> wrote:

> > > From: Stephen Hemminger <stephen@networkplumber.org>
> > >
> > > I want all new users to get the IANA port without asking.
> > > Old users with existing nets have to force the port to the one they
> > > were using.
> > 
> > That'd be great -- what we're getting is all new users are getting
> > a listen port of 8472 and a send port of 4789. So new users who aren't
> > aware of why will simply see that two *new* installations don't talk
> > to each other (and never will, using default ports, because the kernel
> > and ip will need to be compatible with their incompatible selves).
> 
> Could the kernel listen on both port numbers?
> Then the default 'send' port could be changed while maintaining
> functionality for existing systems.
> 
> At some later time the listener on 8372 could be removed.
> 
> 	David
> 
> 
> 

Actually with the destination port per vxlan it is possible to do.

1. Create vxlan0 with old port number
2. Create vxlan1 with new port number
3. Create a bridge vxlanbr0
4. Put both vxlan's into the bridge

Then the bridge will silently handle finding the correct port
and allow migrating other hosts to the new port number.
