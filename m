From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Wed, 29 Sep 2004 19:59:36 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929095936.GB29516@gondor.apana.org.au>
References: <1096451623.415a862783d87@www.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, pablo@eurodev.net, davem@davemloft.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Chapman <jchapman@katalix.com>
Content-Disposition: inline
In-Reply-To: <1096451623.415a862783d87@www.katalix.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 29, 2004 at 10:53:43AM +0100, James Chapman wrote:
> 
> - Have the kernel keep a list of async messages sent towards each
>   socket rather than trying to deliver each message to the app
>   immediately.  Have the kernel send a netlink event message (say,
>   NETLINK_EVENT_WAKEUP) to the app when this queue first goes
>   non-empty. No new NETLINK_EVENT_WAKEUP messages are sent until the
>   event queue goes empty again.
> 
> - On receipt of NETLINK_EVENT_WAKEUP, a process issues a netlink
>   GET (or DUMP?) on its netlink socket to read its queued events.
> 
> - If the socket event queue overruns, discard new events and flag the
>   event queue as having lost messages. When the userspace app reads
>   the event queue, it will discover that messages have been lost and
>   can then re-read state from the kernel.
> 
> - Use a setsockopt on the netlink socket to have the socket configured
>   in this polled-event mode.

That's basically how it works now.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
