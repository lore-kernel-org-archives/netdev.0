From: Zach Brown <zach.brown@oracle.com>
Subject: Re: [take5 1/4] kevent: Core files.
Date: Tue, 08 Aug 2006 15:02:59 -0700
Message-ID: <44D90A13.4070704@oracle.com>
References: <11550230871019@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tetsuo.zabbo.net ([207.173.201.20]:37309 "EHLO tetsuo.zabbo.net")
	by vger.kernel.org with ESMTP id S1030305AbWHHWDE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 18:03:04 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <11550230871019@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> +++ b/include/linux/kevent.h

 ...

> +#ifdef CONFIG_KEVENT_SOCKET
> +
> +extern struct file_operations socket_file_ops;

This doesn't build because socket_file_ops was left static in net/socket.c.

In any case, kevent.h has no business exposing socket_file_ops to users
of the kevent api just so the kevent core can test files as being backed
by sockets.  It'd be more appropriate to call into the socket layer with
the filp and let it return -EINVAL or -ESOCKNOOPT instead of trying to
do that in the kevent layer.

- z
