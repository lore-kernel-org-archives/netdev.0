From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute2] regression in ss output
Date: Wed, 18 Oct 2017 19:11:16 +0200
Message-ID: <20171018171116.GC32305@orbyte.nwl.cc>
References: <AM4PR0901MB125261BF480B49D2BA2DF46BCC480@AM4PR0901MB1252.eurprd09.prod.outlook.com>
 <20171016103320.GP11332@orbyte.nwl.cc>
 <AM4PR0901MB12527C55F04814777A0E6849CC4F0@AM4PR0901MB1252.eurprd09.prod.outlook.com>
 <20171016142807.47825131@xeon-e3>
 <1508205636.31614.81.camel@edumazet-glaptop3.roam.corp.google.com>
 <20171016194958.669625db@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Humberto Alves <hjalves@live.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:47458 "EHLO orbyte.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750853AbdJRRLS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Oct 2017 13:11:18 -0400
Content-Disposition: inline
In-Reply-To: <20171016194958.669625db@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 16, 2017 at 07:49:58PM -0700, Stephen Hemminger wrote:
> On Mon, 16 Oct 2017 19:00:36 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > On Mon, 2017-10-16 at 14:28 -0700, Stephen Hemminger wrote:
> > > On Mon, 16 Oct 2017 20:44:07 +0000
> > > Humberto Alves <hjalves@live.com> wrote:
> > >   
> > > > Yes, just get rid of this 'if statement'.
> > > > in6addr_any should be represented as '::', not '*'. Otherwise it's 
> > > > impossible to distinguish IPv4 listening addresses from IPv6. Thank you :)  
> > > 
> > > But IPv6 accepts IPv4 as well.  
> > 
> > Not always (IPV6_V6ONLY socket option)
> > 
> > I agree that this recent change in ss is problematic.
> > 
> > Please give us back a way to distinguish IPV6 and IPv4
> 
> What about
> 	*:80	<< both IPV6 and IPV4
> 	[::]:80	<< IPV6_ONLY
> 	0.0.0.0:80  << IPV4_ONLY

Assuming that this will be distinguished based on INET_DIAG_SKV6ONLY
attribute, tc will then use the asterisk for v6only sockets on older
kernels not supporting the feature.

Fine with me, just a heads-up!

Cheers, Phil
