From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netns: deinline net_generic()
Date: Thu, 16 Apr 2015 05:38:15 -0700
Message-ID: <1429187895.7346.195.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1429014311-19868-1-git-send-email-dvlasenk@redhat.com>
	 <20150414.143747.1155055158701231768.davem@davemloft.net>
	 <552F9986.30207@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ebiederm@xmission.com,
	jengelh@medozas.de, jpirko@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Denys Vlasenko <dvlasenk@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:35518 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753327AbbDPMiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 08:38:17 -0400
In-Reply-To: <552F9986.30207@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-16 at 13:14 +0200, Denys Vlasenko wrote:

> However, without BUG_ONs, function is still a bit big
> on PREEMPT configs.

Only on allyesconfig builds, that nobody use but to prove some points
about code size.

If you look at net_generic(), it is mostly used from code that is
normally in 3 modules. How many people really load them ?

net/tipc : 91 call sites
net/sunrpc : 57
fs/nfsd & fs/lockd : 183

Then few remaining uses in tunnels.

As we suggested, please just remove the BUG_ON().

Then, if you can come up with a solution that does not slow down non
PREEMPT kernel, why not.
