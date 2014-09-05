From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [Patch net] ipv6: restore the behavior of ipv6_sock_ac_drop()
Date: Sat, 06 Sep 2014 00:26:25 +0200
Message-ID: <1409955985.1192797.164218289.4192DDA7@webmail.messagingengine.com>
References: <1409952780-24471-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Sabrina Dubroca <sd@queasysnail.net>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:50161 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751211AbaIEW00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 18:26:26 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by gateway2.nyi.internal (Postfix) with ESMTP id 8E6D820DA7
	for <netdev@vger.kernel.org>; Fri,  5 Sep 2014 18:26:25 -0400 (EDT)
In-Reply-To: <1409952780-24471-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Cong,

Just doing normal review, really no bad intentions, just technical
follow-up. ;)

On Fri, Sep 5, 2014, at 23:33, Cong Wang wrote:
> It is possible that the interface is already gone after joining
> the list of anycast on this interface as we don't hold a refcount
> for the device, in this case we are safe to ignore the error.

anycast code actually inserts routes into the routing table and holds a
reference on the interface while that route is active.

> What's more important, for API compatibility we should not
> change this behavior for applications even if it were correct.

IMHO adding new error codes never breaks existing applications because
there is no way they can explore all possible errno variables. Also we
already report ENODEV from multicast setsockopts. So I think it would be
ok to leave it as is, but I have no strong opinion on that and it would
be ok by me if the patch got accepted (maybe update the changelog).

Thanks,
Hannes
