From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Thu, 30 Sep 2004 10:50:09 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096537809.415bd6d13f7b3@www.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: hadi@cyberus.ca, pablo@eurodev.net, davem@davemloft.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> On Wed, Sep 29, 2004 at 10:53:43AM +0100, James Chapman wrote:
> >
> > - Have the kernel keep a list of async messages sent towards each
> >   socket rather than trying to deliver each message to the app
> >   immediately.  Have the kernel send a netlink event message (say,
> >   NETLINK_EVENT_WAKEUP) to the app when this queue first goes
> >   non-empty. No new NETLINK_EVENT_WAKEUP messages are sent until the
> >   event queue goes empty again.
> >
> > - On receipt of NETLINK_EVENT_WAKEUP, a process issues a netlink
> >   GET (or DUMP?) on its netlink socket to read its queued events.
> >
> > - If the socket event queue overruns, discard new events and flag the
> >   event queue as having lost messages. When the userspace app reads
> >   the event queue, it will discover that messages have been lost and
> >   can then re-read state from the kernel.
> >
> > - Use a setsockopt on the netlink socket to have the socket configured
> >   in this polled-event mode.
>
> That's basically how it works now.

Looks like I was proposing something similar to Jamal's intermediate
queue. With the above scheme, there would be no need for userspace to
periodically poll for events since that would be kicked off by the
wakeup message. Also, while events are held in the kernel, they
wouldn't be charged to the netlink socket -- instead they'd be limited
by a system-wide count, sharing the event resource across all netlink
sockets.

/james
