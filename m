From: Dawid Ciezarkiewicz <dpc@asn.pl>
Subject: Re: [RFC] wrr (weighted round-robin) bonding
Date: Tue, 17 Oct 2006 10:16:21 +0200
Message-ID: <200610171016.21964.dpc@asn.pl>
References: <200610162021.12884.dpc@asn.pl> <200610162107.57477.dpc@asn.pl> <20061016213053.GA16231@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from apollo.asn.pl ([85.14.104.1]:59081 "HELO apollo.asn.pl")
	by vger.kernel.org with SMTP id S1422961AbWJQIQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 04:16:29 -0400
To: Andy Gospodarek <andy@greyhouse.net>
In-Reply-To: <20061016213053.GA16231@gospo.rdu.redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, 16 October 2006 23:30, Andy Gospodarek wrote:
> On Mon, Oct 16, 2006 at 09:07:57PM +0200, Dawid Ciezarkiewicz wrote:
> > > 
> > > 	Before getting into the technical bits of the patch, what's the
> > > reason for wanting to do this, and why is this rather complex manual
> > > weight assignment better than an automatic system based on, e.g., link
> > > speed of the slaves?
> > 
> > In short:
> > It was designed as a solution for wireless links bonding - where link 
quality 
> > can change rather quickly in time. By using wrr bonding, userspace tools 
can 
> > measure current bandwidth and change bonding slave weights in realtime.
> 
> Since this is so similar to mode 0, it would seem there would be a way
> to extend it rather than creating yet another mode that is so similar.
> What would be the reason not to enhance that mode?

In fact - as default weight is being set to 1, without changing it wrr bonding 
mode works like plain round-robin one. But it have little more overhead 
(recharging tokens), and code is a bit more complicated. I was not sure if 
some tools could assume that in mode 0 all interfaces work with same weights 
and because of that behave strange with this patch in use. 

It was written as a solution for some problem, and I'm still not sure if such 
change will always be patch to linux kernel or may some day go into mainline. 
For compatibility I've decided to have those modes separated.

Because of that I haven't replaced mode 0. If this patch will be considered 
useful, and my concerns are not a problem - I'd like to replace 0 mode if 
possible.
