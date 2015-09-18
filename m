From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: xfrm4_garbage_collect reaching limit
Date: Fri, 18 Sep 2015 06:49:43 +0200
Message-ID: <20150918044943.GC7701@secunet.com>
References: <20150911094808.GI25499@secunet.com>
 <CAOZ2QJPAb4PfoBybPuhMokh9jhRFY0XSNMajf75Mgx=3=KXfUg@mail.gmail.com>
 <20150916084541.GB7701@secunet.com>
 <20150917.212335.346651920275379240.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <dan.streetman@canonical.com>, <ddstreet@ieee.org>,
	<jay.vosburgh@canonical.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:47880 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750713AbbIREtr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Sep 2015 00:49:47 -0400
Content-Disposition: inline
In-Reply-To: <20150917.212335.346651920275379240.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 17, 2015 at 09:23:35PM -0700, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Wed, 16 Sep 2015 10:45:41 +0200
> 
> > index 1e06c4f..3dffc73 100644
> > --- a/net/ipv4/xfrm4_policy.c
> > +++ b/net/ipv4/xfrm4_policy.c
> > @@ -248,7 +248,7 @@ static struct dst_ops xfrm4_dst_ops = {
> >  	.destroy =		xfrm4_dst_destroy,
> >  	.ifdown =		xfrm4_dst_ifdown,
> >  	.local_out =		__ip_local_out,
> > -	.gc_thresh =		32768,
> > +	.gc_thresh =		INT_MAX,
> >  };
> >  
> >  static struct xfrm_policy_afinfo xfrm4_policy_afinfo = {
> 
> This means the dst_ops->gc() for xfrm will never be invoked.
> 
> Is that intentional?

Yes. This is already the case on systems with less than 8 cpus
because the flowcache is limited to 4096 entries per cpu. The
percpu flowcache shrinks itself to 'low_watermark' enrires if
it hits the percpu limit.
