From: lepton <ytht.net@gmail.com>
Subject: why we use skb->rt->rt_src as dest address when replying packet?
Date: Wed, 16 May 2007 18:29:35 +0800
Message-ID: <20070516102934.GA26934@router.lepton.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:10360 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754775AbXEPK3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 06:29:52 -0400
Received: by py-out-1112.google.com with SMTP id a29so440400pyi
        for <netdev@vger.kernel.org>; Wed, 16 May 2007 03:29:51 -0700 (PDT)
Received: from lepton by router.lepton.home with local (Exim 4.50)
	id 1HoGlD-0000S1-14
	for netdev@vger.kernel.org; Wed, 16 May 2007 18:29:35 +0800
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I found in function [ip_send_reply] and [icmp_reply], we
use such code to get the destination address of our
packet:

struct rtable *rt = (struct rtable *)skb->dst;
......
daddr = ipc.addr = rt->rt_src;

I have a question here:
Is there any special reason for using rt->rt_src as destination address?
Can I use codes like these?

struct iph * ip = skb->nh.iph;
......
daddr = ipc.addr = ip->saddr;

I found in some case, rt->rt_src is not equal to ip->saddr. Thanks.
