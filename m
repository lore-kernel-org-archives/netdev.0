From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] af_unix: fix a fatal race with bit fields
Date: Wed, 1 May 2013 08:10:54 -0700
Message-ID: <20130501081054.267a7851@nehalam.linuxnetplumber.net>
References: <1367370761.11020.22.camel@edumazet-glaptop>
	<20130501115103.58e40f37@kryten>
	<1367375060.11020.24.camel@edumazet-glaptop>
	<20130501035425.GD5221@bubble.grove.modra.org>
	<1367384672.11020.34.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alan Modra <amodra@gmail.com>, Anton Blanchard <anton@samba.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org,
	Paul Mackerras <paulus@samba.org>,
	Ambrose Feinstein <ambrose@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f49.google.com ([209.85.210.49]:52143 "EHLO
	mail-da0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755937Ab3EAPLI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 11:11:08 -0400
Received: by mail-da0-f49.google.com with SMTP id t11so703772daj.36
        for <netdev@vger.kernel.org>; Wed, 01 May 2013 08:11:08 -0700 (PDT)
In-Reply-To: <1367384672.11020.34.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Apr 2013 22:04:32 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Wed, 2013-05-01 at 13:24 +0930, Alan Modra wrote:
> > On Tue, Apr 30, 2013 at 07:24:20PM -0700, Eric Dumazet wrote:
> > > 	li 11,1
> > > 	ld 0,0(9)
> > > 	rldimi 0,11,31,32
> > > 	std 0,0(9)
> > > 	blr
> > > 	.ident	"GCC: (GNU) 4.6.3"
> > > 
> > > You can see "ld 0,0(9)" is used : its a 64 bit load.
> > 
> > Yup.  This is not a powerpc64 specific problem.  See
> > http://gcc.gnu.org/bugzilla/show_bug.cgi?id=52080
> > Fixed in 4.8.0 and 4.7.3.
> 
> Ah thanks.
> 
> This seems a pretty serious issue, is it documented somewhere that
> ppc64, sparc64 and others need such compiler version ?
> 
> These kind of errors are pretty hard to find, its a pity to spend time
> on them.

There is a checkbin target inside arch/powerpc/Makefile
Shouldn't a check be added there to block building kernel with known
bad GCC versions?
