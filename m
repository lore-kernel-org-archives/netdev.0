From: David Miller <davem@davemloft.net>
Subject: Re: Null dereference in socket.c
Date: Fri, 28 Sep 2007 16:00:57 -0700 (PDT)
Message-ID: <20070928.160057.132434706.davem@davemloft.net>
References: <46FD871C.2080004@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: cebbert@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49524
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751598AbXI1XA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 19:00:57 -0400
In-Reply-To: <46FD871C.2080004@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chuck Ebbert <cebbert@redhat.com>
Date: Fri, 28 Sep 2007 18:58:36 -0400

> After debugging an oops (https://bugzilla.redhat.com/attachment.cgi?id=209231)
> I find it happens here in socket.c::sock_ioctl() line 902:
> 
>                default:
> =============>          err = sock->ops->ioctl(sock, cmd, arg);
> 
>                         /*
>                          * If this ioctl is unknown try to hand it down
>                          * to the NIC driver.
>                          */
>                         if (err == -ENOIOCTLCMD)
>                                 err = dev_ioctl(cmd, argp);
>                         break;
> 
> 
> ioctl is NULL and the kernel jumps to address 0. Should we add a check
> for that?
> 
> Bug report:
> https://bugzilla.redhat.com/show_bug.cgi?id=306801

Every protocol should provide a non-NULL ->ioctl() method,
find out which one isn't and fix it.
