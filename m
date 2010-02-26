From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] net: sock_aio_write: set CMSG_MSG_COMPAT flag if
 is_compat_task
Date: Fri, 26 Feb 2010 01:17:51 -0800 (PST)
Message-ID: <20100226.011751.20505389.davem@davemloft.net>
References: <1266583307-3049-1-git-send-email-fwestphal@astaro.com>
	<1266583307-3049-6-git-send-email-fwestphal@astaro.com>
	<20100226.011646.257642830.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net
To: fwestphal@astaro.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41221
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935646Ab0BZJRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 04:17:33 -0500
In-Reply-To: <20100226.011646.257642830.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 26 Feb 2010 01:16:46 -0800 (PST)

> From: Florian Westphal <fwestphal@astaro.com>
> Date: Fri, 19 Feb 2010 13:41:47 +0100
> 
>> @@ -837,6 +837,10 @@ static ssize_t do_sock_write(struct msghdr *msg, struct kiocb *iocb,
>>  	msg->msg_iov = (struct iovec *)iov;
>>  	msg->msg_iovlen = nr_segs;
>>  	msg->msg_flags = (file->f_flags & O_NONBLOCK) ? MSG_DONTWAIT : 0;
>> +#ifdef CONFIG_COMPAT
>> +	if (is_compat_task())
>> +		msg->msg_flags |= MSG_CMSG_COMPAT;
>> +#endif
>>  	if (sock->type == SOCK_SEQPACKET)
>>  		msg->msg_flags |= MSG_EOR;
>>  
> 
> What if the kernel itself does a socket write, say from a software
> interrupt or to generate events in response to a user event,
> and the current process happens to be a compat task?

BTW, it's again another example of why is_compat_task() is almost
always the wrong thing to use.

