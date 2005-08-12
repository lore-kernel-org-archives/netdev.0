From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Strange uses of netif_start_queue
Date: Fri, 12 Aug 2005 11:00:34 -0700 (PDT)
Message-ID: <20050812.110034.63126875.davem@davemloft.net>
References: <1123853714.22460.39.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: alan@lxorguk.ukuu.org.uk
In-Reply-To: <1123853714.22460.39.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Fri, 12 Aug 2005 14:35:14 +0100

> Something I noticed doing the tty work. the 6pack driver calls
> netif_start_queue() before it calls register_netdev. I'm curious if this
> is allowed ?

It's definitely a bug, and when register_netdev() happens it will
just overwrite that change of state.

Since the queue is not initialized yet, this could also cause
a crash or hang. :-)
