From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH] net/rds: using strlcpy instead of strncpy
Date: Mon, 4 Mar 2013 18:32:24 +0000
Message-ID: <1362421944.2956.15.camel@bwh-desktop.uk.solarflarecom.com>
References: <512F1534.9020404@asianux.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B716D@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Chen Gang <gang.chen@asianux.com>,
	<venkat.x.venkatsubra@oracle.com>,
	David Miller <davem@davemloft.net>, <rds-devel@oss.oracle.com>,
	netdev <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:20796 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754493Ab3CDScl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 13:32:41 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B716D@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-28 at 09:36 +0000, David Laight wrote:
> >   when src strlen is sizeof(ctr.name) - 1, the dest str is not '\0' end.
> >   better use strlcpy instead.
> > 
> > Signed-off-by: Chen Gang <gang.chen@asianux.com>
> > ---
> >  net/rds/stats.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/net/rds/stats.c b/net/rds/stats.c
> > index 7be790d..b9ac1df 100644
> > --- a/net/rds/stats.c
> > +++ b/net/rds/stats.c
> > @@ -86,7 +86,7 @@ void rds_stats_info_copy(struct rds_info_iterator *iter,
> > 
> >  	for (i = 0; i < nr; i++) {
> >  		BUG_ON(strlen(names[i]) >= sizeof(ctr.name));
> > -		strncpy(ctr.name, names[i], sizeof(ctr.name) - 1);
> > +		strlcpy(ctr.name, names[i], sizeof(ctr.name));
> >  		ctr.value = values[i];
> > 
> 
> If the target buffer ends up being copied to userspace that
> might lead to random kernel memory being leaked.

Seems it is.  The last byte of 'name' is not currently initialised and
therefore is already leaked to userland.

But it's OK because rds_info_copy() uses memcpy() not __copy_to_user(),
so SMAP will block this leak. :-)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
