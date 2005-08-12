From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Strange uses of netif_start_queue
Date: Fri, 12 Aug 2005 20:46:05 +0200
Message-ID: <20050812184605.GK10481@postel.suug.ch>
References: <1123853714.22460.39.camel@localhost.localdomain> <20050812.110034.63126875.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alan@lxorguk.ukuu.org.uk, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050812.110034.63126875.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <20050812.110034.63126875.davem@davemloft.net> 2005-08-12 11:00
> From: Alan Cox <alan@lxorguk.ukuu.org.uk>
> Date: Fri, 12 Aug 2005 14:35:14 +0100
> 
> > Something I noticed doing the tty work. the 6pack driver calls
> > netif_start_queue() before it calls register_netdev. I'm curious if this
> > is allowed ?
> 
> It's definitely a bug, and when register_netdev() happens it will
> just overwrite that change of state.
> 
> Since the queue is not initialized yet, this could also cause
> a crash or hang. :-)

Hmm, maybe I got something wrong but:

As you say correctly, there is no way we can queue packets until
the device has been put up, a device cannot be put up while it is
not present but that doesn't happen before register_netdevice()
so the value of the queue bit doesn't matter at all. Actually the
default state is indeed to have the queue running (bit set to 0)
so the mentioned netif_start_queue() is a simple nop as Patrick
noted already. It will _not_ be overwritten by a call to
register_netdevice() though which is a good thing: It allows the
queue to be stopped from the very beginning without a race between
register_netdevice() and the call to netif_stop_queue().
