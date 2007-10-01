From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] memory leak in netlink user->kernel processing
Date: Mon, 01 Oct 2007 17:03:23 +0200
Message-ID: <47010C3B.7040902@trash.net>
References: <20071001142907.GA10022@iris.sw.ru> <470105EA.3090209@trash.net> <47010B07.5060009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Denis V. Lunev" <den@openvz.org>, davem@davemloft.net,
	netdev@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>
To: "Denis V. Lunev" <dlunev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34955 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbXJAPHN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 11:07:13 -0400
In-Reply-To: <47010B07.5060009@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denis V. Lunev wrote:
> By the way, Patrick, this looks like nlk->pid == 0 if and only if this
> is a kernel socket. Right?
>   

Thats correct.

> I have told with Alexey Kuznetsov and we have discrovered a way to get
> rid of
>         skb_queue_tail(&sk->sk_receive_queue, skb);
>         sk->sk_data_ready(sk, len);
> in netlink_sendskb/etc for kernel sockets and make user->kernel packets
> processing truly synchronous.
>
> The idea is simple, we should queue/wakeup in kernel->user direction and
> simply call nlk->data_ready for user->kernel direction. This will remove
> all the crap we have now. But we need a mark to determine the direction.
> Which one will be better? (nlk->data_ready) or (nlk->pid == 0)


Both would work fine, but I think nlk->pid is better since its
actually the "address".


