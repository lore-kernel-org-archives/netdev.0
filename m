From: Simon Horman <horms@verge.net.au>
Subject: Re: Update ip command line processing
Date: Fri, 21 Dec 2007 10:32:08 +0900
Message-ID: <20071221013206.GB21843@verge.net.au>
References: <20071218085730.GA10765@verge.net.au> <20071220.152121.188610437.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	apw@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:47364 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751521AbXLUBcK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 20:32:10 -0500
Content-Disposition: inline
In-Reply-To: <20071220.152121.188610437.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 20, 2007 at 03:21:21PM -0800, David Miller wrote:
> From: Simon Horman <horms@verge.net.au>
> Date: Tue, 18 Dec 2007 17:57:32 +0900
> 
> > @@ -1414,9 +1414,16 @@ late_initcall(ip_auto_config);
> >   */
> >  static int __init ic_proto_name(char *name)
> >  {
> > +	if (!name) {
> > +		return 1;
> > +	}
> 
> I do not see any circumstance under which this pointer can
> be NULL.  Judging by your other changes, I think you mean
> to use "!*name" here.
> 
> Maybe:
> 
> 	if (*name == '\0')
> 
> would make it clearer what you're checking for, an
> empty string.
> 
> Otherwise I'm fine with your change.

Sorry, I meant if (*name == '\0') as you suggest to replace the first
portion of:

-	ic_enable = (*addrs &&
-		(strcmp(addrs, "off") != 0) &&
-		(strcmp(addrs, "none") != 0));

I'll send an updated patch shortly.

-- 
Horms

