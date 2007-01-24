From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] decnet: handle a failure in neigh_parms_alloc
Date: Wed, 24 Jan 2007 14:49:52 -0800 (PST)
Message-ID: <20070124.144952.02299886.davem@davemloft.net>
References: <m13b601917.fsf@ebiederm.dsl.xmission.com>
	<20070124.144511.56810202.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve@chygwyn.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46018
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752081AbXAXWuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 17:50:17 -0500
In-Reply-To: <20070124.144511.56810202.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Wed, 24 Jan 2007 14:45:11 -0800 (PST)

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Wed, 24 Jan 2007 13:09:40 -0700
> 
> > 
> > While enhancing the neighbour code to handle multiple network
> > namespaces I noticed that decnet is assuming neigh_parms_alloc
> > will allways succeed, which is clearly wrong.  So handle the
> > failure.
> > 
> > Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> 
> I don't think this one is correct.
> 
> During failure cleanup you also have to invoke the neighbour parms
> ->down() operation if present, else you leave multicast entries on the
> ethernet device for example.

BTW, it occurs to me that a good way to handle this might be to
try and do the neigh_parms_alloc() before running the ->up()
method.
