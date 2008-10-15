From: Steven Whitehouse <swhiteho@redhat.com>
Subject: Re: decnet: Fix complier warning
Date: Wed, 15 Oct 2008 13:40:35 +0100
Message-ID: <1224074435.25004.87.camel@quoit>
References: <1224073160.25004.85.camel@quoit>
	 <1224074238.3984.169.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@vger.kernel.org,
	Christine Caulfield <ccaulfie@redhat.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:52731 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752737AbYJOMmG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Oct 2008 08:42:06 -0400
In-Reply-To: <1224074238.3984.169.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, 2008-10-15 at 13:37 +0100, Ben Hutchings wrote:
> On Wed, 2008-10-15 at 13:19 +0100, Steven Whitehouse wrote:
> > This patch fixes a warning seen during compiling dn_dev.c. The warning is harmless
> > since we know that the structure length in question is less than 2^32 bytes, but
> > this fixes it anyway.
> > 
> > Signed-off-by: Steven Whitehouse <swhiteho@redhat.com>
> > Cc: Christine Caulfield <ccaulfie@redhat.com>
> > 
> > diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
> > index 2f0ac3c..d9bc69c 100644
> > --- a/net/decnet/dn_dev.c
> > +++ b/net/decnet/dn_dev.c
> > @@ -152,7 +152,7 @@ static struct dn_dev_parms dn_dev_list[] =  {
> >  
> >  #define DN_DEV_LIST_SIZE ARRAY_SIZE(dn_dev_list)
> >  
> > -#define DN_DEV_PARMS_OFFSET(x) ((int) ((char *) &((struct dn_dev_parms *)0)->x))
> > +#define DN_DEV_PARMS_OFFSET(x) ((long) ((char *) &((struct dn_dev_parms *)0)->x))
> >  
> >  #ifdef CONFIG_SYSCTL
> >  
> 
> Or you could make this use offsetof().  Daring, I know, it's only been a
> standard macro for nearly 20 years.
> 
> Ben.
> 
Yes, thats true. The whole set of code is rather suspect to say the
least and I was going for the minimal fix. Its a long time since I last
looked at this code so I don't remember exactly why it was done in that
way,

Steve.


