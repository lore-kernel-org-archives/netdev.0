From: Jeremy <poseng@gmail.com>
Subject: IPv6: finding a match in =?utf-8?b?ZmluZF9ycl9sZWFm?= that cause a NULL pointer dereference
Date: Wed, 27 May 2015 06:28:19 +0000 (UTC)
Message-ID: <loom.20150527T081417-915@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:37172 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751777AbbE0GaH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 May 2015 02:30:07 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1YxUqq-0001FL-6c
	for netdev@vger.kernel.org; Wed, 27 May 2015 08:30:04 +0200
Received: from pgdmzpr04-ext.png.intel.com ([pgdmzpr04-ext.png.intel.com])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 08:30:04 +0200
Received: from poseng by pgdmzpr04-ext.png.intel.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 08:30:04 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

My kernel is 3.10.20 and I encountered this NULL pointer dereference.

According to my log, I found that dev is NULL in the beginning of for 
loop. it is the dev of rr_head that has been set to NULL. That might be 
possible that dev being NULL but I don't see any case to avoid such case 
in rt6_check_dev(), even the kernel 4.0.

Don't know if my concern is necessary or not or there has a mechanism in 
somewhere that I hadn't been noticed.

Any comment of my concern is welcome and thanks for your time to review my 
post.

for (rt = rr_head; rt && rt->rt6i_metric == metric; rt = rt->dst.rt6_next)
    match = find_match(rt, oif, strict, &mpri, match, do_rr);
  --> rt6_score_route(rt, oif, strict);
    --> rt6_check_dev(rt, oif);
     --> struct net_device *dev = rt->dst.dev;
     --> if (!oif || dev->ifindex == oif) <------NULL pointer dereference 
on dev object.
