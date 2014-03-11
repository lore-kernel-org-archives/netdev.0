From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 0/2] remove netpoll rx support
Date: Tue, 11 Mar 2014 12:49:07 -0400 (EDT)
Message-ID: <20140311.124907.1180556684992271103.davem@davemloft.net>
References: <20140311.004217.1616529960369263682.davem@davemloft.net>
	<1394514158.21721.7.camel@edumazet-glaptop2.roam.corp.google.com>
	<87a9cxf7mp.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56698 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752669AbaCKQtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 12:49:09 -0400
In-Reply-To: <87a9cxf7mp.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 11 Mar 2014 01:43:10 -0700

> Furthermore netpoll by it's design depends on the ability to receive
> packets in netpoll_poll_dev.  It is a capability I don't think we have
> ever used in the mainline kernel but it is a capability that is there
> deliberately.  Which means if we want netpoll to not mess with the rx
> path we need to change netpoll.

This breaks kdump, and any other users of netpoll_rx() et al.

Make the zero budget depend upon us being invoked from hardware
irq context, or something like that.

Thanks.
