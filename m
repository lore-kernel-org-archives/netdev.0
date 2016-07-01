From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] notifier: Fix soft lockup for notifier_call_chain().
Date: Fri, 01 Jul 2016 07:12:24 +0200
Message-ID: <1467349944.11238.26.camel@edumazet-glaptop3.roam.corp.google.com>
References: <57720369.6040507@huawei.com>
	 <1467090824.6850.185.camel@edumazet-glaptop3.roam.corp.google.com>
	 <5772149D.6040304@huawei.com>
	 <1467094963.6850.189.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1467095271.6850.192.camel@edumazet-glaptop3.roam.corp.google.com>
	 <5775DE23.40101@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: luto@kernel.org, mingo@kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Cong Wang <cwang@twopensource.com>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:35595 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426AbcGAFTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 01:19:43 -0400
In-Reply-To: <5775DE23.40101@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-07-01 at 11:06 +0800, Ding Tianhong wrote:

> I debug this problem, and found that the __fib6_clean_all() would not
> hold the cpu more than 1 second event though there
> is a lot of ipv6 address to deal with, but the notifier_chian would
> call the ipv6 notifier several times and hold the cpu
> for a long time, so add cond_resched() in the addrconf_ifdown could
> solve the problem correctly, I think your first solution
> is the good way to fix this bug.

I am traveling these days, so please send an official patch once you've
tested it, thanks !
