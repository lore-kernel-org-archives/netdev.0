From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH net-2.6.24] introduce MAC_FMT/MAC_ARG
Date: Wed, 29 Aug 2007 19:46:23 +0200
Message-ID: <200708291946.24017.mb@bu3sch.de>
References: <1188248263.18004.131.camel@localhost> <200708281648.44352.mb@bu3sch.de> <20070828.155419.74563234.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, johannes@sipsolutions.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:48583
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753636AbXH2RsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 13:48:22 -0400
In-Reply-To: <20070828.155419.74563234.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 29 August 2007 00:54:19 David Miller wrote:
> From: Michael Buesch <mb@bu3sch.de>
> Date: Tue, 28 Aug 2007 16:48:44 +0200
> 
> > On Monday 27 August 2007 23:11:50 David Miller wrote:
> > > From: Joe Perches <joe@perches.com>
> > > Date: Mon, 27 Aug 2007 13:57:42 -0700
> > > 
> > > > On Mon, 2007-08-27 at 13:41 -0700, David Miller wrote:
> > > > > From: Johannes Berg <johannes@sipsolutions.net>
> > > > > Date: Mon, 27 Aug 2007 12:54:09 +0200
> > > > > > #define MAC_FMT "%s"
> > > > > > #define MAC_ARG(a) ({char __buf[18]; print_mac(a, __buf); __buf;})
> > > > 
> > > > > I don't think this works.
> > > > 
> > > > $ cat test_fmt.c
> > > > #include <stdio.h>
> > > > #include <stdlib.h>
> > > 
> > > You're just getting lucky in this test case.
> > > 
> > > The language does not allow what you are doing, so you're
> > > playing with fire.
> > 
> > What exactly to you think it invalid in this code?
> > I think it's fine (except that I'd chose an u8* for the mac
> > address (first arg in print_mac()).
> 
> The __buf[] is used out of scope, therefore it's stack space is
> fair game for the compiler to reuse.
> 
> When the compiler sees:
> 
> 	printk(FMT, ({ char __buf[x]; print_mac(a, __buf); __buf;}));
> 
> It first all of the printk() argument expressions, first FMT and
> then it evaluates the ({ ... }) argument.
> 
> Now that the ({ ... }) expression is done, __buf[] is out of
> scope and illegal to reference.
> 
> printk() is now called, with a pointer to an out-of-scope buffer.
> This is illegal.
> 
> I don't know how else to explain this to you, I can learn how to
> describe the issue in German if this would help :-)

Oh, not needed. I see the bug and indeed, this is a ticking
timebomb.
I don't use the ({}) notation a lot, so I didn't see this here.

-- 
Greetings Michael.
