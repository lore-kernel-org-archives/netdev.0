From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/9] genetlink: reduce ops size and complexity (v2)
Date: Sun, 17 Nov 2013 10:12:04 +0100
Message-ID: <1384679524.14795.7.camel@jlt4.sipsolutions.net>
References: <1384445687-30948-1-git-send-email-johannes@sipsolutions.net>
	 <20131114.171204.1979806323628158355.davem@davemloft.net>
	 <1384521515.14295.2.camel@jlt4.sipsolutions.net>
	 <20131115.205313.1543711974325231353.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wimax@intel.com,
	bsingharora@gmail.com, netfilter-devel@vger.kernel.org,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:60502 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752268Ab3KQJMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Nov 2013 04:12:10 -0500
In-Reply-To: <20131115.205313.1543711974325231353.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-15 at 20:53 -0500, David Miller wrote:

> > We could instead register an array of pointers to the groups:
> > 
> > static const struct mcast_group *my_groups[] = {
> >       &my_foo_mcast_group,
> >       ...
> > };
> > 
> > and pass this to the family - that'd still be less space (one pointer
> > for each group rather than two in a linked list) and still allow all
> > groups and this array to be const, but it's not quite as big a
> > saving ...
> > 
> > Thoughts?
> 
> This idea sounds fine.  I don't even thing the array indexing is
> odd, especially if we can have named mnenomics for the indices
> or similar.

I posted something yesterday, but forgot to reply here - basically as
you'll see in the patches, I decided that we should pass the
family/group array index instead of passing the global group identifier
- this will also prevent new users of the APIs from abusing them like
quota/dropmonitor unfortunately did.

johannes
