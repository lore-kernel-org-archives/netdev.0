From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 5/5] ss: Show inet and unix sockets' shutdown state
Date: Thu, 25 Oct 2012 10:09:22 -0700
Message-ID: <20121025100922.12ed2061@nehalam.linuxnetplumber.net>
References: <50893BAF.7030500@parallels.com>
	<50893E14.60001@parallels.com>
	<20121025085229.3aa43b68@nehalam.linuxnetplumber.net>
	<1351184010.6537.158.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59019 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946118Ab2JYRKL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2012 13:10:11 -0400
In-Reply-To: <1351184010.6537.158.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Oct 2012 18:53:30 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Thu, 2012-10-25 at 08:52 -0700, Stephen Hemminger wrote:
> > On Thu, 25 Oct 2012 17:26:44 +0400
> > Pavel Emelyanov <xemul@parallels.com> wrote:
> > 
> > > To see this we need kernel >=3.7 with _SHUTDOWN nlarrts in diag messages.
> > > The output will look like arrows at the end of each line, like this:
> > > 
> > > ESTAB 0 0  127.0.0.1:41705  127.0.0.1:12345  ino:143321 sk:ffff88003a8cea00 -->
> > > ESTAB 0 0  127.0.0.1:46925  127.0.0.1:12346  ino:143322 sk:ffff88003a8ce4c0 <--
> > > ESTAB 0 0  127.0.0.1:51678  127.0.0.1:12347  ino:143323 sk:ffff88003a8cdf80 ---
> > > ESTAB 0 0  127.0.0.1:46911  127.0.0.1:12348  ino:143324 sk:ffff88003b7f05c0 <->
> > > 
> > > for SHUT_RD, SHUT_WR, SHUT_RDWR and non-shutdown sockets respectively.
> > > 
> > > Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> > > 
> > > ---
> > >  include/linux/inet_diag.h |    3 ++-
> > >  include/linux/unix_diag.h |    1 +
> > >  misc/ss.c                 |   26 ++++++++++++++++++++------
> > >  3 files changed, 23 insertions(+), 7 deletions(-)
> > > 
> > > diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
> > > index 8c469af..bbde90f 100644
> > > --- a/include/linux/inet_diag.h
> > > +++ b/include/linux/inet_diag.h
> > > @@ -109,9 +109,10 @@ enum {
> > >  	INET_DIAG_TOS,
> > >  	INET_DIAG_TCLASS,
> > >  	INET_DIAG_SKMEMINFO,
> > > +	INET_DIAG_SHUTDOWN,
> > >  };
> > 
> > Since this requires 3.8 or later kernel, please resubmit this
> > patch during that merge window.
> > --
> 
> I am wondering what possibly could happen if applying this before ?
> 
> iproute2 should be non dependent on kernel version, we make sure to not
> add regressions.
> 
> 
> 

I don't want the stashed kernel headers to get out of date with kernel exported ones.

People who want to test early features are free to build their own pre-release versions.
