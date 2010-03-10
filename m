From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] bnx2x: fix tx queue locking and memory barriers
Date: Wed, 10 Mar 2010 09:49:21 -0800 (PST)
Message-ID: <20100310.094921.211568569.davem@davemloft.net>
References: <20100225140834.0169e9f2@dhcp-lab-109.englab.brq.redhat.com>
	<31355.1268240990@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sgruszka@redhat.com, vladz@broadcom.com,
	paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	eilong@broadcom.com
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49810
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932065Ab0CJRtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 12:49:05 -0500
In-Reply-To: <31355.1268240990@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Wed, 10 Mar 2010 17:09:50 +0000

> The barrier() didn't tell the compiler that fp->tx_bd_prod and fp->tx_bd_cons
> could change.  What it did was to say that the accesses to those two variables
> must be performed after all the other accesses issued by that CPU prior to the
> barrier - at least as far as the compiler is concerned.

barrier() has a "memory" asm clobber which says that all memory could
have changed.
