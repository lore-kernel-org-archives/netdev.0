From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 5/5] ss: Show inet and unix sockets' shutdown state
Date: Thu, 25 Oct 2012 18:53:30 +0200
Message-ID: <1351184010.6537.158.camel@edumazet-glaptop>
References: <50893BAF.7030500@parallels.com> <50893E14.60001@parallels.com>
	 <20121025085229.3aa43b68@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:48515 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933024Ab2JYQxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 12:53:34 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so707223eek.19
        for <netdev@vger.kernel.org>; Thu, 25 Oct 2012 09:53:33 -0700 (PDT)
In-Reply-To: <20121025085229.3aa43b68@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-25 at 08:52 -0700, Stephen Hemminger wrote:
> On Thu, 25 Oct 2012 17:26:44 +0400
> Pavel Emelyanov <xemul@parallels.com> wrote:
> 
> > To see this we need kernel >=3.7 with _SHUTDOWN nlarrts in diag messages.
> > The output will look like arrows at the end of each line, like this:
> > 
> > ESTAB 0 0  127.0.0.1:41705  127.0.0.1:12345  ino:143321 sk:ffff88003a8cea00 -->
> > ESTAB 0 0  127.0.0.1:46925  127.0.0.1:12346  ino:143322 sk:ffff88003a8ce4c0 <--
> > ESTAB 0 0  127.0.0.1:51678  127.0.0.1:12347  ino:143323 sk:ffff88003a8cdf80 ---
> > ESTAB 0 0  127.0.0.1:46911  127.0.0.1:12348  ino:143324 sk:ffff88003b7f05c0 <->
> > 
> > for SHUT_RD, SHUT_WR, SHUT_RDWR and non-shutdown sockets respectively.
> > 
> > Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> > 
> > ---
> >  include/linux/inet_diag.h |    3 ++-
> >  include/linux/unix_diag.h |    1 +
> >  misc/ss.c                 |   26 ++++++++++++++++++++------
> >  3 files changed, 23 insertions(+), 7 deletions(-)
> > 
> > diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
> > index 8c469af..bbde90f 100644
> > --- a/include/linux/inet_diag.h
> > +++ b/include/linux/inet_diag.h
> > @@ -109,9 +109,10 @@ enum {
> >  	INET_DIAG_TOS,
> >  	INET_DIAG_TCLASS,
> >  	INET_DIAG_SKMEMINFO,
> > +	INET_DIAG_SHUTDOWN,
> >  };
> 
> Since this requires 3.8 or later kernel, please resubmit this
> patch during that merge window.
> --

I am wondering what possibly could happen if applying this before ?

iproute2 should be non dependent on kernel version, we make sure to not
add regressions.
