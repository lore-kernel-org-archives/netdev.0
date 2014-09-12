From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [Patch net-next] ipv6: exit early in addrconf_notify() if IPv6
 is disabled
Date: Fri, 12 Sep 2014 22:18:19 +0200
Message-ID: <1410553099.2970.18.camel@localhost>
References: <1410473236-3346-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5295 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751726AbaILUS3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2014 16:18:29 -0400
In-Reply-To: <1410473236-3346-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Cong,

On Do, 2014-09-11 at 15:07 -0700, Cong Wang wrote:
> If IPv6 is explicitly disabled before the interface comes up,
> it makes no sense to continue when it comes up, even just
> print a message.
> 
> (I am not sure about other cases though, so I prefer not to touch)
> 
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

I checked the other notifier_blocks, I don't think we need to change
anything there.

disable_ipv6 is absolutely bad implemented. It should not be in the ipv6
procfs namespace at all. An inet6_dev must be available to manage this
knob! Thus we are automagically subscribed to all ipv6 LL multicast
groups.

I don't see any problems with this patch:
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,
Hannes
