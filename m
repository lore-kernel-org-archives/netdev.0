From: jamal <hadi@cyberus.ca>
Subject: Re: [tproxy,regression] tproxy broken in 2.6.32
Date: Fri, 27 Nov 2009 11:05:32 -0500
Message-ID: <1259337932.3299.3.camel@bigi>
References: <db81a9a20911230443h443b3c2l8fab5aef7b09cfa@mail.gmail.com>
	 <1259137434.9191.3.camel@nienna.balabit>
	 <db81a9a20911260919w1ffded25ref5ae24ee73f8eda@mail.gmail.com>
	 <1259310417.3809.5.camel@nienna.balabit>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andreas Schultz <aschultz@warp10.net>, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org
To: KOVACS Krisztian <hidden@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f192.google.com ([209.85.221.192]:55979 "EHLO
	mail-qy0-f192.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751162AbZK0QF2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 11:05:28 -0500
Received: by qyk30 with SMTP id 30so736290qyk.33
        for <netdev@vger.kernel.org>; Fri, 27 Nov 2009 08:05:34 -0800 (PST)
In-Reply-To: <1259310417.3809.5.camel@nienna.balabit>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-11-27 at 09:26 +0100, KOVACS Krisztian wrote:
> Hi,
> 
> On Thu, 2009-11-26 at 18:19 +0100, Andreas Schultz wrote:
> > Hi,
> > 
> > git bisect shows that TPROXY has been broken by commit
> > f7c6fd2465d8e6f4f89c5d1262da10b4a6d499d0, [PATCH] net: Fix RPF to work
> > with policy routing
> > 
> > I had a look at the patch, and it seems logical that this would break TPROXY.
> 
> Indeed, that's a good catch. If this is indeed the problem you should be
> able to work it around by disabling rpfilter on the ingress interface.
> Does it work that way?

Not familiar with tproxy, but I suspect the system doesnt see the mark
before policy routing happens. So probably the wrong route cache gets
created. Easy to validate by dumping the route cache.
If thats so, you have to set the mark in pre-route hook if it uses
iptables.

cheers,
jamal


