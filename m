From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: em_canid: remove useless statements from
 em_canid_change
Date: Sun, 22 Jun 2014 17:27:07 -0700 (PDT)
Message-ID: <20140622.172707.816044847520857805.davem@davemloft.net>
References: <53A15267.7050304@cn.fujitsu.com>
	<20140621.154036.2087202508923213287.davem@davemloft.net>
	<53A703F6.9090507@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: duanj.fnst@cn.fujitsu.com, lisovy@gmail.com, netdev@vger.kernel.org
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49687 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785AbaFWA1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2014 20:27:08 -0400
In-Reply-To: <53A703F6.9090507@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Sun, 22 Jun 2014 18:27:34 +0200

> This is right for the first set of filters that is ever configured in
> em_canid_change().
> 
> But what happens in an update case?
> Does is turn the cm_old reference to a memory leak then?
> 
> Or do we always get a brand new "struct tcf_ematch *m" here??

There is only one call to this method is tcf_em_validate(), which also
unconditionally assigns new pointers to em->data without checking if
an existing non-NULL value is in em->data.  Specifically in the code
path where em->ops->change is not implemented.
