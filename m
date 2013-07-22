From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH iproute2 1/2] ss: Fix compiler errors of unused
 return-values
Date: Mon, 22 Jul 2013 18:26:37 +0100
Message-ID: <1374513997.1635.22.camel@bwh-desktop.uk.level5networks.com>
References: <1374350298-1177-1-git-send-email-christoph.paasch@uclouvain.be>
	 <1374350298-1177-2-git-send-email-christoph.paasch@uclouvain.be>
	 <1374507539.4990.17.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Christoph Paasch <christoph.paasch@uclouvain.be>,
	Stephen Hemminger <stephen@networkplumber.org>,
	<netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:60880 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932409Ab3GVR0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 13:26:42 -0400
In-Reply-To: <1374507539.4990.17.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-22 at 08:38 -0700, Eric Dumazet wrote:
> On Sat, 2013-07-20 at 21:58 +0200, Christoph Paasch wrote:
> > Many errors when compiling with gcc 4.7.3 about unused return-values
> > upon the calls to fgets and fscanf:
> >
> 
> > For the calls to fscanf we can't really do anything about it, and just
> > do an empty if-statement to make the compiler happy.
> > 
> > Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> > ---
> >  misc/ss.c | 30 +++++++++++++++++++++---------
> >  1 file changed, 21 insertions(+), 9 deletions(-)
> > 
> > diff --git a/misc/ss.c b/misc/ss.c
> > index c0369f1..0f71108 100644
> > --- a/misc/ss.c
> > +++ b/misc/ss.c
> > @@ -302,7 +302,7 @@ static void user_ent_hash_build(void)
> >  
> >  				snprintf(tmp, sizeof(tmp), "%s/%d/stat", root, pid);
> >  				if ((fp = fopen(tmp, "r")) != NULL) {
> > -					fscanf(fp, "%*d (%[^)])", process);
> > +					if (fscanf(fp, "%*d (%[^)])", process) == EOF);
> 
> This is really ugly :(

It is.  And gcc doesn't accept casting to void to suppress the warning.
Maybe add a wrapper fscanf_with_output_already_set_to_default()? ;-)  Or
do what glibc expects and set the defaults only when fscanf() reads less
than we wanted:

	switch (fscanf(p, "...", &foo, &bar, ...)) {
	case EOF:
	case 0: foo = ...;
	case 1: bar = ...;
	...
	}

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
