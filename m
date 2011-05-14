From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: netlink: don't try unicast when dst_pid is zero for NETLINK_USERSOCK
Date: Sat, 14 May 2011 08:50:37 +0800
Message-ID: <BANLkTimXZ0gU0F0SpmUuUwEsnD3MGSnJcA@mail.gmail.com>
References: <1305267894-3314-1-git-send-email-xiaosuo@gmail.com> <20110513.164816.691741982303119913.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f173.google.com ([209.85.212.173]:34897 "EHLO
	mail-px0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759816Ab1ENAu5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 20:50:57 -0400
Received: by pxi16 with SMTP id 16so1989365pxi.4
        for <netdev@vger.kernel.org>; Fri, 13 May 2011 17:50:57 -0700 (PDT)
In-Reply-To: <20110513.164816.691741982303119913.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 14, 2011 at 4:48 AM, David Miller <davem@davemloft.net> wrote:
> From: Changli Gao <xiaosuo@gmail.com>
> Date: Fri, 13 May 2011 14:24:54 +0800
>
>> For NETLINK_USERSOCK, no one listens on PID 0, so sending a message only to
>> to a multicast group should not return -ECONNREFUSED.
>>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>
> I don't think this is a great idea, creating different semantics for
> NETLINK_USERSOCK vs. other types.
>
> You have to set the pid to something which will receive the unicast
> message, and then you can also (on top of that) send it to a multicast
> group as well.
>
> But the base operation is always the unicast send, and that is what
> determines success/failure of the operation.
>

Yes, I have seen that the return value of netlink_broadcast() isn't
returned to the caller, so the caller can't know whether the message
broadcasted is sent successfully or not. It isn't a big problem, as
netlink isn't a reliable datagram protocol. Without this patch
applied, we can also send a message to a multicast group only, but
ignore the -ECONNREFUSED error.

Thanks.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
