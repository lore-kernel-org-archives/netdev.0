From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCHv2 ipsec-next] xfrm: Namespacify xfrm_policy_sk_bundles
Date: Wed, 18 Dec 2013 05:33:58 +0000 (UTC)
Message-ID: <slrnlb2cuh.32c.xiyou.wangcong@linux-6brj.site>
References: <1387337658-28951-1-git-send-email-fan.du@windriver.com>
 <1387342211.19078.295.camel@edumazet-glaptop2.roam.corp.google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:38987 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751540Ab3LRFeU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 00:34:20 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Vt9m0-0007eg-1S
	for netdev@vger.kernel.org; Wed, 18 Dec 2013 06:34:20 +0100
Received: from c-24-5-209-215.hsd1.ca.comcast.net ([24.5.209.215])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 06:34:20 +0100
Received: from xiyou.wangcong by c-24-5-209-215.hsd1.ca.comcast.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 06:34:20 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Dec 2013 at 04:50 GMT, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2013-12-18 at 11:34 +0800, Fan Du wrote:
>> -
>> -			spin_lock_bh(&net->xfrm.xfrm_policy_sk_bundle_lock);
>> -			xdst->u.dst.next = xfrm_policy_sk_bundles;
>> -			xfrm_policy_sk_bundles = &xdst->u.dst;
>> -			spin_unlock_bh(&net->xfrm.xfrm_policy_sk_bundle_lock);
>> -
>> +			xdst->u.dst.next = xchg(&net->xfrm.xfrm_policy_sk_bundles,
>> +						&xdst->u.dst);
>
> This is not safe.
>
> Take a look at include/linux/llist.h if you really want to avoid the
> spinlock.
>

Exactly, xfrm_policy_sk_bundles list is only traversed after deletion.
