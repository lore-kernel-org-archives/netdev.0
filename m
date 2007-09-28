From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Null dereference in socket.c
Date: Fri, 28 Sep 2007 16:42:42 -0700
Message-ID: <20070928164242.540b945a@freepuppy.rosehill>
References: <46FD871C.2080004@redhat.com>
	<20070928.160057.132434706.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: cebbert@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34163 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754575AbXI1Xmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 19:42:53 -0400
In-Reply-To: <20070928.160057.132434706.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 Sep 2007 16:00:57 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Chuck Ebbert <cebbert@redhat.com>
> Date: Fri, 28 Sep 2007 18:58:36 -0400
> 
> > After debugging an oops (https://bugzilla.redhat.com/attachment.cgi?id=209231)
> > I find it happens here in socket.c::sock_ioctl() line 902:
> > 
> >                default:
> > =============>          err = sock->ops->ioctl(sock, cmd, arg);
> > 
> >                         /*
> >                          * If this ioctl is unknown try to hand it down
> >                          * to the NIC driver.
> >                          */
> >                         if (err == -ENOIOCTLCMD)
> >                                 err = dev_ioctl(cmd, argp);
> >                         break;
> > 
> > 
> > ioctl is NULL and the kernel jumps to address 0. Should we add a check
> > for that?
> > 
> > Bug report:
> > https://bugzilla.redhat.com/show_bug.cgi?id=306801
> 
> Every protocol should provide a non-NULL ->ioctl() method,
> find out which one isn't and fix it

Auditing the net-2.6.24 tree all instances found by cscope are safe.

	


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
