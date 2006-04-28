From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 28 Apr 2006 10:41:18 -0700
Message-ID: <20060428104118.6a056a59@localhost.localdomain>
References: <54AD0F12E08D1541B826BE97C98F99F143B0F3@NT-SJCA-0751.brcm.ad.broadcom.com>
	<20060428101833.2f0d6ae8@localhost.localdomain>
	<20060428172932.GB16916@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Caitlin Bestler <caitlinb@broadcom.com>,
	"David S. Miller" <davem@davemloft.net>, kelly@au1.ibm.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:12714 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751189AbWD1Rlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 13:41:46 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060428172932.GB16916@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 Apr 2006 21:29:32 +0400
Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> On Fri, Apr 28, 2006 at 10:18:33AM -0700, Stephen Hemminger (shemminger@osdl.org) wrote:
> > Please just use existing AIO interface.  We don't need another
> > interface. The number of interfaces increases the exposed bug
> > surface geometrically.  Which means for each new interface, it
> > means testing and fixing bugs in every possible usage.
> 
> Networking AIO? Like [1] :)
> That would be really good.
> 
> 1. http://tservice.net.ru/~s0mbre/old/?section=projects&item=naio
> 

The existing infrastructure is there in the syscall layer, it just
isn't really AIO for sockets. That naio project has two problems, first
they require driver changes, and he is doing it on the stupidest
of hardware, optimizing a 8139too is foolish. Second, introducing
kevents, seems unnecessary and hasn't been accepted in the mainline.

The existing linux AIO model seems sufficient:
	http://lse.sourceforge.net/io/aio.html

There is work to put true Posix AIO on top of this.



	
