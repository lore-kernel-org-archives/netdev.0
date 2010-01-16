From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4/ip_sockglue.c: copy msg_control optval from user
 to kernel space
Date: Fri, 15 Jan 2010 17:30:44 -0800 (PST)
Message-ID: <20100115.173044.102257749.davem@davemloft.net>
References: <201001151024.59482.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: hartleys@visionengravers.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46871
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932392Ab0APBah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 20:30:37 -0500
In-Reply-To: <201001151024.59482.hartleys@visionengravers.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: H Hartley Sweeten <hartleys@visionengravers.com>
Date: Fri, 15 Jan 2010 10:24:59 -0700

> ipv4/ip_sockglue.c: copy msg_control optval from user to kernel space
> 
> In do_ip_getsockopt the char __user *optval is used directly in
> IP_PKTOPTIONS for the msg.msg_control and not copied from
> user to kernel address space. This produces a sparse warning:
> 
> warning: incorrect type in assignment (different address spaces)
>    expected void *msg_control
>    got char [noderef] <asn:1>*optval
> 
> Fix this by using copy _from_user to set msg.msg_control.
> 
> Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>

This isn't right.

We want the 'optval' pointer itself, not the data it points to, stored
in msg.msg_control

And 'msg_control' is, in this case a user pointer.

It just isn't annotated (along with the rest of struct msghdr) with
"__user" because we mix the usage of this object with kernel and user
pointers.

How did you test your change?
