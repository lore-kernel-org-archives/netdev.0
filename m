From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [PATCH 10/13] NetLabel: use cipso_v4_doi_search() for local CIPSOv4 functions
Date: Fri, 24 Nov 2006 05:53:59 +0000
Message-ID: <20061124055358.GN3078@ftp.linux.org.uk>
References: <20061117223842.399078000@hp.com> <20061117224336.711076000@hp.com> <1164331474.2079.39.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paul.moore@hp.com, netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	jmorris@namei.org, Alexander Viro <aviro@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:39602 "EHLO
	ZenIV.linux.org.uk") by vger.kernel.org with ESMTP id S934363AbWKXFyH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Nov 2006 00:54:07 -0500
To: Eric Paris <eparis@parisplace.org>
Content-Disposition: inline
In-Reply-To: <1164331474.2079.39.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 23, 2006 at 08:24:34PM -0500, Eric Paris wrote:
> On Fri, 2006-11-17 at 17:38 -0500, paul.moore@hp.com wrote:
> 
> > Index: net-2.6.20_netlabel-base-work/net/ipv4/cipso_ipv4.c
> > ===================================================================
> > --- net-2.6.20_netlabel-base-work.orig/net/ipv4/cipso_ipv4.c
> > +++ net-2.6.20_netlabel-base-work/net/ipv4/cipso_ipv4.c
> > @@ -1136,7 +1136,7 @@ int cipso_v4_validate(unsigned char **op
> >  	}
> >  
> >  	rcu_read_lock();
> > -	doi_def = cipso_v4_doi_getdef(ntohl(*((__be32 *)&opt[2])));
> > +	doi_def = cipso_v4_doi_search(ntohl(*((u32 *)&opt[2])));
> >  	if (doi_def == NULL) {
> >  		err_offset = 2;
> >  		goto validate_return_locked;
> 
> 
> This appears to reverse the previous endian work by Al Viro, was this
> intended?

Mismerge, most likely.  Fixed in net-2.6.20 since then (
commit 835ec2525544c744333bf0da00049f323eb75c58
Author: Al Viro <viro@zeniv.linux.org.uk>
Date:   Mon Nov 20 18:08:37 2006 -0800

    [CIPSO]: Missing annotation in cipso_ipv4 update.
) 

Note that there are two changes in that line - u32 -> __be32 and
..._getdef -> ..._search.  They do not really conflict, but any merge
tool would throw a conflict at that point and apparently it got
resolved the dumb way...
