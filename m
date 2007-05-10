From: David Miller <davem@davemloft.net>
Subject: Re: Kernel BUG: NULL pointer dereference , reference to sys_recvmsg
Date: Thu, 10 May 2007 14:21:38 -0700 (PDT)
Message-ID: <20070510.142138.54188362.davem@davemloft.net>
References: <547a31ab0705100712w740e8fbuece5013d05a449b9@mail.gmail.com>
	<464389A2.6080606@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: croulder@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: cebbert@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56451
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755616AbXEJVVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 17:21:35 -0400
In-Reply-To: <464389A2.6080606@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chuck Ebbert <cebbert@redhat.com>
Date: Thu, 10 May 2007 17:07:46 -0400

> Here in sys_recvmsg() line 1911:
> 
> ==>     if (sock->file->f_flags & O_NONBLOCK)
>                 flags |= MSG_DONTWAIT;
>         err = sock_recvmsg(sock, &msg_sys, total_len, flags);
> 
> sock == -1, apparently because that's what sockfd_lookup_light() 
> returned earlier in the function. (It doesn't check err, just
> that the returned sock is nonzero.)

sockfd_lookup_light() returns NULL in all cases where 'err'
is set non-zero.

I suspect file->private_data has been corrupted somehow.
