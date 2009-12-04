From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: pull request: SCTP updates for net-next
Date: Fri, 4 Dec 2009 12:52:33 -0800
Message-ID: <20091204125233.eea7de39.akpm@linux-foundation.org>
References: <4B0AF96A.3050709@hp.com>
	<20091203210050.d886f229.akpm@linux-foundation.org>
	<4B193772.9010109@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux SCTP Dev Mailing list <linux-sctp@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrei Pelinescu-Onciul <andrei@iptel.org>
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33485 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932380AbZLDUxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 15:53:05 -0500
In-Reply-To: <4B193772.9010109@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 04 Dec 2009 11:23:14 -0500
Vlad Yasevich <vladislav.yasevich@hp.com> wrote:

> > 
> > Overall, it would be way simpler and saner to clamp this value to some
> > explicit time period, IMO.
> > 
> > <pulls number out of thin air>
> > 
> > --- a/net/sctp/socket.c~a
> > +++ a/net/sctp/socket.c
> > @@ -2086,9 +2086,8 @@ static int sctp_setsockopt_autoclose(str
> >  		return -EINVAL;
> >  	if (copy_from_user(&sp->autoclose, optval, optlen))
> >  		return -EFAULT;
> > -	/* make sure it won't exceed MAX_SCHEDULE_TIMEOUT */
> > -	if (sp->autoclose > (MAX_SCHEDULE_TIMEOUT / HZ) )
> > -		sp->autoclose = MAX_SCHEDULE_TIMEOUT / HZ ;
> > +	/* make sure it won't exceed one hour */
> > +	sp->autoclose = min_t(u32, sp->autoclose, 60 * 60);
> >  
> 
> But that may not be long enough.  The spec doesn't impose limits
> and it's really up to the application to decide how long it wants
> to keep idle connections open.  Thus any limits shorter the maximum
> supported by kernel are really artificial and may not be sufficient.

Could make ->autoclose a u64?  That fixes any 32bit-vs-64bit
inconsistencies and allows for an effectively infinite period.

