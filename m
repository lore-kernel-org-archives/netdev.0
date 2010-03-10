From: David Howells <dhowells@redhat.com>
Subject: Re: [RFC PATCH] bnx2x: fix tx queue locking and memory barriers
Date: Wed, 10 Mar 2010 18:32:50 +0000
Message-ID: <318.1268245970@redhat.com>
References: <20100310.094921.211568569.davem@davemloft.net> <20100225140834.0169e9f2@dhcp-lab-109.englab.brq.redhat.com> <31355.1268240990@redhat.com>
Cc: dhowells@redhat.com, sgruszka@redhat.com, vladz@broadcom.com,
	paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	eilong@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1025 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932708Ab0CJSc5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Mar 2010 13:32:57 -0500
In-Reply-To: <20100310.094921.211568569.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:

> > The barrier() didn't tell the compiler that fp->tx_bd_prod and
> > fp->tx_bd_cons could change.  What it did was to say that the accesses to
> > those two variables must be performed after all the other accesses issued
> > by that CPU prior to the barrier - at least as far as the compiler is
> > concerned.
> 
> barrier() has a "memory" asm clobber which says that all memory could
> have changed.

Indeed, but only as far as the compiler is concerned.

However, the problem is almost certainly not this, but that the item to be
read from the buffer may not have been written yet by the producing CPU, even
though it's written the head pointer.

David
