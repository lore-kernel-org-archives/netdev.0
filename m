From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [RFC PATCH V4 12/13] netfront: multi page ring support.
Date: Fri, 17 Feb 2012 10:10:56 -0500
Message-ID: <20120217151056.GB29554@phenom.dumpdata.com>
References: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
 <1328201363-13915-13-git-send-email-wei.liu2@citrix.com>
 <20120215224253.GA18762@phenom.dumpdata.com>
 <1329386571.4520.44.camel@leeds.uk.xensource.com>
 <1329387379.4520.54.camel@leeds.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:19909 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751712Ab2BQPOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 10:14:08 -0500
Content-Disposition: inline
In-Reply-To: <1329387379.4520.54.camel@leeds.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > -#define XENNET_MAX_RING_PAGE_ORDER 2
> > > +#define XENNET_MAX_RING_PAGE_ORDER 4
> > 
> > I guess this is you tuning with page order? And here is not the only one
> > place you changed?
> > 
> > As a matter of fact, in the previous patch 8 I encode hard limit 2 on
> > the ring page order, your change here will stop FE / BE from connecting.
> > 
> > I think I will also need to change this to something like
> > 
> >   #define XENNET_MAX_RING_PAGE_ORDER XENBUS_MAX_RING_PAGE_ORDER
> > 
> > to remind people to modify that value. 
> > 
> 
> To be more precise on this, tangling with RING_PAGE_ORDER will not
> affect FE, because the mapping is done in BE. However if you make
> RING_PAGE_ORDER larger than BE limit, it will fail.
> 
> So the above #define is actually asking people playing with FE to check
> BE limit. :-(

Say that in two years we decide that the ring order in the FE should be 256,
and we also change that in the backend. Some customers might still be running
with the old backends which advertise only 4.

Or vice-versa. The users run a brand new BE which advertises 256 and the user
is running a frontend that can only do 4. It (frontend) should be able to safely
negotiate the proper minimum value.
