From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.25-rc8: FTP transfer errors
Date: Thu, 10 Apr 2008 23:46:29 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804101147070.24841@wrl-59.cs.helsinki.fi>
References: <47FCF9DD.6080007@rtr.ca> <20080410.023045.16227424.yoshfuji@linux-ipv6.org>
 <47FD138B.2060801@rtr.ca> <20080409.152933.132174258.davem@davemloft.net>
 <47FD590C.5020003@rtr.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org,
	Jeff Garzik <jeff@garzik.org>, rjw@sisk.pl,
	LKML <linux-kernel@vger.kernel.org>, linux-net@vger.kernel.org,
	Netdev <netdev@vger.kernel.org>
To: Mark Lord <lkml@rtr.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42932 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755332AbYDJUqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 16:46:33 -0400
In-Reply-To: <47FD590C.5020003@rtr.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 9 Apr 2008, Mark Lord wrote:

> David Miller wrote:
> > From: Mark Lord <lkml@rtr.ca>
> > Date: Wed, 09 Apr 2008 15:05:47 -0400
> > 
> > > But it would be far more useful for whoever has been working on the
> > > stack to suggest some possible/likely commits to look at instead.
> > 
> > Personally all I see is that one side closes the socket before all
> > data packets received have been read into the application, resulting
> > in a (correct) reset going out.
> > 
> > I can't think of any change we've made over the course of this
> > release that would change behvaior in that area.
> > 
> > So you will likely need to bisect.
> ..
> 
> Or I can ignore it, like the net developers, since I have a workaround.
> And then we'll see what other apps are broken upon 2.6.25 final release.
> 
> Really, folks.  Bug reports are intended to *help* the developers,
> not something to be thrown back in their faces.
> 
> There do seem to have been a *lot* of changes around the tcp closing/close
> code (as I see from diff'ing 2.6.24 against latest -git).

Sure, if you count in all whitespace/indentation/code moving changes to 
that as well... :-)

> *Somebody* is responsible for those changes.
> That particular *somebody* ought to volunteer some help here,

I might help if would add netdev on cc list in case you really want to 
reac net developers, otherwise they might just end up "ignoring it"... ;-)

> reducing the mountain of commits to a big handful or two.

Those touching fin/close are mostly whitespace/move things, so I doubt 
that you find these useful but in case you insist, here's the list:

056834d9f6f6eaf4cc7268569e53acab957aac27 [TCP]: cleanup tcp_{in,out}put.c style
058dc3342b71ffb3531c4f9df7c35f943f392b8d [TCP]: reduce tcp_output's indentation levels a bit
490d5046930276aae50dd16942649bfc626056f7 [TCP]: Uninline tcp_set_state

In addition, there's this one (...though I have read it number of times 
through and still cannot catch something that would cause the wrongness 
you're seeing):

e870a8efcddaaa3da7e180b6ae21239fb96aa2bb [TCP]: Perform setting of common 
control fields in one place

There's very little really on interesting side I can think of, mostly 
thinks are congestion control related changes... ...maybe either one of 
these could cause something unpleasant in some corner case:

bd515c3e48ececd774eb3128e81b669dbbd32637 [TCP]: Fix TSO deferring
0e3a4803aa06cd7bc2cfc1d04289df4f6027640a [TCP]: Force TSO splits to MSS boundaries

...e.g., if the latter causes a return with zero limit under some 
conditions, tso_fragment might generate, well, interesting packets and 
never finish if the condition persists but.


-- 
 i.
