From: Hangbin Liu <haliu@redhat.com>
Subject: Re: [PATCH iproute2] ip route: check ftell, fseek return value
Date: Wed, 7 Sep 2016 21:50:40 +0800
Message-ID: <20160907135040.GA2861@leo.usersys.redhat.com>
References: <1473143990-9291-1-git-send-email-liuhangbin@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB00F5252@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Hangbin Liu'" <liuhangbin@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Phil Sutter <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45356 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751499AbcIGNuq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Sep 2016 09:50:46 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB00F5252@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 06, 2016 at 11:18:00AM +0000, David Laight wrote:
> From: Hangbin Liu
> > Sent: 06 September 2016 07:40
> > ftell() may return -1 in error case, which is not handled and therefore pass a
> > negative offset to fseek(). The return code of fseek() is also not checked.
> > 
> > Reported-by: Phil Sutter <phil@nwl.cc>
> > Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> > ---
> >  ip/iproute.c | 11 +++++++++--
> >  1 file changed, 9 insertions(+), 2 deletions(-)
> > 
> > diff --git a/ip/iproute.c b/ip/iproute.c
> > index 3da23af..ba877dc 100644
> > --- a/ip/iproute.c
> > +++ b/ip/iproute.c
> > @@ -1859,7 +1859,11 @@ static int iproute_restore(void)
> >  	if (route_dump_check_magic())
> >  		exit(-1);
> > 
> > -	pos = ftell(stdin);
> > +	if ((pos = ftell(stdin)) == -1) {
> 
> Don't put assignments in conditionals.
> 
> > +		perror("Failed to restore: ftell");
> > +		exit(errno);
> 
> errno is not a valid argument to exit().

Hi David,

Thanks for the advice. I will send PATCHv2 to fix them.

> 
> ...
> 
> Actually WTF is this code trying to do.
> stdin is vere likely to be a pipe, so expecting to seek on it
> seems very likely to fail.

I will fix the return code handle issue first and try investigate the pipe
issue later.

Regards
Hangbin
