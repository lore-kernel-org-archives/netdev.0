From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [PATCH] rtnetlink: Fix error handling in do_setlink()
Date: Fri, 21 May 2010 23:52:12 -0700
Message-ID: <20100522065212.GW8301@sequoia.sous-sol.org>
References: <20100521122527.20442.77793.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Chris Wright <chrisw@sous-sol.org>,
	"David S. Miller" <davem@davemloft.net>
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sous-sol.org ([216.99.217.87]:36237 "EHLO sequoia.sous-sol.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751888Ab0EVGw3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 May 2010 02:52:29 -0400
Content-Disposition: inline
In-Reply-To: <20100521122527.20442.77793.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* David Howells (dhowells@redhat.com) wrote:
> Commit c02db8c6290bb992442fec1407643c94cc414375:
> 
> 	Author:  Chris Wright <chrisw@sous-sol.org>
> 	Date:    Sun May 16 01:05:45 2010 -0700
> 	Subject: rtnetlink: make SR-IOV VF interface symmetric
> 
> adds broken error handling to do_setlink() in net/core/rtnetlink.c.  The
> problem is the following chunk of code:
> 
> 	if (tb[IFLA_VFINFO_LIST]) {
> 		struct nlattr *attr;
> 		int rem;
> 		nla_for_each_nested(attr, tb[IFLA_VFINFO_LIST], rem) {
> 			if (nla_type(attr) != IFLA_VF_INFO)
>   ---->				goto errout;
> 			err = do_setvfinfo(dev, attr);
> 			if (err < 0)
> 				goto errout;
> 			modified = 1;
> 		}
> 	}
> 
> which can get to errout without setting err, resulting in the following error:
> 
> net/core/rtnetlink.c: In function 'do_setlink':
> net/core/rtnetlink.c:904: warning: 'err' may be used uninitialized in this function
> 
> Change the code to return -EINVAL in this case.  Note that this might not be
> the appropriate error though.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

Acked-by: Chris Wright <chrisw@sous-sol.org>

Thank you David, that's correct.  I have some other pending changes
here, so I don't mind collecting them together.

thanks,
-chris
