From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2.6 NET] Device name changing via rtnetlink
Date: Fri, 10 Sep 2004 22:22:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040910202235.GK20088@postel.suug.ch>
References: <20040910195003.GA13912@bougret.hpl.hp.com> <20040910200644.GJ20088@postel.suug.ch> <20040910201302.GA16556@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
Content-Disposition: inline
In-Reply-To: <20040910201302.GA16556@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Jean Tourrilhes <20040910201302.GA16556@bougret.hpl.hp.com> 2004-09-10 13:13
> On Fri, Sep 10, 2004 at 10:06:44PM +0200, Thomas Graf wrote:
> > * Jean Tourrilhes <20040910195003.GA13912@bougret.hpl.hp.com> 2004-09-10 12:50
> > > Thomas Graf wrote :
> > > > 
> > > > Allows changing of device name via rtnetlink. Last bit needed to do full
> > > > link configuration via rtnetlink.
> > > > 
> > > > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> > > 
> > > 	This does not work, because you don't return the new name to
> > > user space. If the new name is a pattern, such as "eth%d" or "wlan%d",
> > > you absolutely need to return the new instanciated device name to user
> > > space so that userspace doesn't loose track of the device.
> > 
> > The ifindex stays the same, therefore the user space application can
> > simply dump the link list and fetch the new interface name.
> 
> 	It's so simple to return the new name, so why not do it ?
> There is no need to make applications more complex.

Oh, I didn't realize that, can you enlighten me?

> > It would
> > theoretically be possible to provide the new name via an ACK but
> > this would break the RFC.
> 
> 	What do you mean, break the RFC ?

I can think of 2 ways implementing this:

1) Send an ACK and change IFLA_IFNAME in the original message. However,
   RFC 3549 specifies it to be the old message so user space
   applications can directly reuse it (forward, redirect, log, ...)

2) Implement NETDEV_CHANGE, I was actually about to implement this
   but it's not directly related to this change and requires the same
   effort by the user space application has refetching the link list.
