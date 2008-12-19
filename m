From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix module refcount leak in kernel_accept()
Date: Thu, 18 Dec 2008 22:39:26 -0800 (PST)
Message-ID: <20081218.223926.229583681.davem@davemloft.net>
References: <494A23FE.6020305@cn.fujitsu.com>
	<1229668537.17082.15.camel@violet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yjwei@cn.fujitsu.com, netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36056
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751758AbYLSGjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 01:39:24 -0500
In-Reply-To: <1229668537.17082.15.camel@violet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Fri, 19 Dec 2008 07:35:37 +0100

> Hi Wei,
> 
> > The kernel_accept() does not hold the module refcount of newsock->ops->owner,
> > so we need __module_get(newsock->ops->owner) code after call kernel_accept()
> > by hand.
> > In sunrpc, the module refcount is missing to hold. So this cause kernel panic.
> > 
> > Used following script to reproduct:
> > 
> > while [ 1 ];
> > do
> >     mount -t nfs4 192.168.0.19:/ /mnt
> >     touch /mnt/file
> >     umount /mnt
> >     lsmod | grep ipv6
> > done
> > 
> > This patch fixed the problem by add __module_get(newsock->ops->owner) to
> > kernel_accept(). So we do not need to used __module_get(newsock->ops->owner)
> > in every place when used kernel_accept().
> > 
> > Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> > ---
> >  net/bluetooth/rfcomm/core.c |    2 --
> >  net/socket.c                |    1 +
> >  2 files changed, 1 insertions(+), 2 deletions(-)
> 
> I was just about to reply and ask you to double check the users since I
> know that I am using that API. Hey, but you already did that. Thanks.

That's the exact audit I did before applying his patch :-)
