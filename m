From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: oh crap... (re: %p6)
Date: Wed, 29 Oct 2008 10:24:42 -0700
Message-ID: <1225301082.5688.24.camel@brick>
References: <20081029.015402.234525839.davem@davemloft.net>
	 <1225292124.20276.12.camel@brick>  <1225294760.5269.301.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f18.google.com ([209.85.217.18]:52563 "EHLO
	mail-gx0-f18.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752332AbYJ2RYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 13:24:47 -0400
Received: by gxk11 with SMTP id 11so3094841gxk.13
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 10:24:45 -0700 (PDT)
In-Reply-To: <1225294760.5269.301.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-10-29 at 08:39 -0700, Joe Perches wrote:
> On Wed, 2008-10-29 at 07:55 -0700, Harvey Harrison wrote:
> > On Wed, 2008-10-29 at 01:54 -0700, David Miller wrote:
> > > I think we'll need to revert all of this or find some fix soon.  GCC
> > > warns about %p with a '#' flag modifier it seems :-(
> > > 
> > > net/ipv6/ip6_flowlabel.c: In function 'ip6fl_seq_show':
> > > net/ipv6/ip6_flowlabel.c:707: warning: '#' flag used with '%p' printf format
> > 
> > The easiest would be to pick a separate modifier for the raw case.  Or
> > revert the removal of NIP6_SEQFMT, I'll shoot you a patch shortly,
> > any preference in what modifier should be used?
> 
> I'd prefer something visual that represents "no colon".
> 
> Maybe %p6-: 

Putting a modifier after the format specifier seems a little strange to me.  But
I'm not sure if I can think of something that's too much better, currently I
was thinking of:

%pI6, %pi6
	%pI6 would act just like %p6
	%pi6 would act just like %#p6

Eventually %pI4 could be added as well. Which would print out the dot-separated
format.

Either that or add a %px<bytes> that prints out raw hex for the number
of <bytes>, so %p6 would stay and %#p6 would become %px16.  While this
is a bit uglier, it could be useful to others elsewhere in-kernel,
perhaps limited to 16 bytes or so.

Dave, I'll wait for your $0.02 before sending in a patch, but I have
both of the above implemented.

Harvey


