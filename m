From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 01/26] switchdev: introduce get/set attrs
 ops
Date: Thu, 02 Apr 2015 13:54:42 -0400 (EDT)
Message-ID: <20150402.135442.406267578423876673.davem@davemloft.net>
References: <CAE4R7bC+fSjEP+uz19L9mbjf1Y+sPUM=Z7iuDtQdhPAZA1x3sA@mail.gmail.com>
	<20150402.120533.225417156120458098.davem@davemloft.net>
	<CAE4R7bD17Tv+4rFJDFeMQadPB=gj4dNktaT0wU7BksL-PB=NJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40066 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781AbbDBRyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 13:54:49 -0400
In-Reply-To: <CAE4R7bD17Tv+4rFJDFeMQadPB=gj4dNktaT0wU7BksL-PB=NJg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>
Date: Thu, 2 Apr 2015 10:38:56 -0700

> I looked at doing that with rocker for setting STP state.  The driver
> does allocate some system memory blocks, conditionally, about 4 call
> levels down, and then it may or may not free them it.  To do that all
> up-front in prepare, we'd need to traverse all the same code paths
> allocating memory as we go and stashing it in some transaction object
> passed from above, but skip any device accesses.  And then in commit,
> go thru the same paths, but use stash memory from transaction object
> and this time do call into device.  All of this to avoid failing
> commit due to OOM.  So I reasoned OOM isn't a case worth the work
> because the system is pretty much hosed at that point anyway, and went
> with a prepare phase that only validates and checks for device
> resources, but skip system resources.
> 
> It's not impossible, but my little Spring Cleanup patch is going to
> turn into Spring Renovation patch.

I'm sorry if implementing this properly is not easy.

You'll thank me later for forcing you to do this properly, I promise.
:-)
