From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: icmp redirects problem
Date: Tue, 24 Nov 2009 07:58:52 +0000
Message-ID: <20091124075852.GA6170@ff.dom.local>
References: <20091123043124.GA14795@samad.com.au> <4B0B058E.3050906@gmail.com> <20091124001230.GC14245@samad.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Alex Samad <alex@samad.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:49262 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757848AbZKXH6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 02:58:52 -0500
Received: by fg-out-1718.google.com with SMTP id d23so2545041fga.1
        for <netdev@vger.kernel.org>; Mon, 23 Nov 2009 23:58:58 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20091124001230.GC14245@samad.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 24, 2009 at 11:12:30AM +1100, Alex Samad wrote:
> On Mon, Nov 23, 2009 at 10:58:38PM +0100, Jarek Poplawski wrote:
> > Alex Samad wrote, On 11/23/2009 05:31 AM:
> > 
> 
> [snip]
> 
> > > 
> > > laptop gets its ip from dchp server that make 192.168.11.1 the default
> > > gateway and its 192.168.11.1 that sends out the icmp redirect.
> > 
> > Btw, it seems you should fix your routing (by adding sydrt01's eth0
> > the second ip or advertising 192.168.11.10 more) to avoid those
> > redirects.
> 
> sorry I am lost on this statement, I can't add 192.168.11.10 to sydrt01
> as it is not physically connected to the 192.168.10.0/24 any more, which
> is why I had added the route on sydrt01 and which is why it send
> icmp_rediercts.
> 
> I have updated the route table on each static machine, but the problem
> is on the machines that get their ip via dhcp - I haven't looked at
> pushing out route information via dhcp - I am not sure that it would
> work in a mixed windows / linux environment.
> 
> what do you mean by advertising 192.168.11.10 more ?

I meant just what you've described, but wasn't sure of your config.

> 
> > 
> > > 
> > > I had a quick look at the kernel tree for 2.6.31 (which is what I am
> > > using).
> > 
> > ...
> > 
> > > Line 680
> > >  secure_redirects - BOOLEAN
> > >  681         Accept ICMP redirect messages only for gateways,
> > >  682         listed in default gateway list.
> > >  683         secure_redirects for the interface will be enabled if at
> > >  least one of
> > >  684         conf/{all,interface}/secure_redirects is set to TRUE,
> > >  685         it will be disabled otherwise
> > >  686         default TRUE
> > 
> > Very helpful links. So, as you wrote "the documentation seems to suggest"
> > something, and IMHO even if it doesn't, it's needlessly too concise
> > considering your "lost time", and I'd suggest you sending a patch to fix
> > this. (It seems it could "touch" shared_media, as well.)
> 
> Which is wrong the code or the documentation and which part the test or
> the reliance on the shared_media or on the redirects flags

The code looks consistent to me. The documentation isn't wrong either,
until it only "seems to suggest", but it might be better, if it
metioned just what you tested: both things depend on accept_redirects.

Jarek P.
