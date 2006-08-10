From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 1/5] sock_create bad error return
Date: Thu, 10 Aug 2006 10:06:08 -0700
Message-ID: <20060810100608.2737bee5@localhost.localdomain>
References: <20060809183138.332023530@localhost.localdomain>
	<20060809183348.999358659@localhost.localdomain>
	<20060809.204745.102463311.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: paulmck@us.ibm.com, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:45540 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161465AbWHJRKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2006 13:10:15 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060809.204745.102463311.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 09 Aug 2006 20:47:45 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Wed, 09 Aug 2006 11:31:39 -0700
> 
> > If socket create call races with module unload, it correctly
> > fails the socket call but doesn't return an error. This race
> > is theoritical because the sock->ops are always the same and
> > non-modular.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> 
> I think the intention of the code is to return
> -EAFNOSUPPORT which is set explicitly some lines
> above, and this makes sense because if we can't grab
> onto the module reference count it means the module
> is in the process of being unloaded.

It is the module reference count of the socket file ops, not the
protocol family reference count.  The protocol family code is
already handled a few lines above.

Since the socket code can't be built as a module, it is a dead end. I think
in-olden-times the idea was that networking could be built as a module
so that inode ops would have to be ref counted.

