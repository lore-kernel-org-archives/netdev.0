From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] serial: add a new helper function
Date: Sun, 19 Aug 2012 16:46:58 +0100
Message-ID: <20120819164658.1737bb74@pyramind.ukuu.org.uk>
References: <1345400832-23572-1-git-send-email-shijie8@gmail.com>
	<20120819064429.GA3252@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Huang Shijie <shijie8@gmail.com>, alan@linux.intel.com,
	jirislaby@gmail.com, linux-kernel@vger.kernel.org,
	linux-serial@vger.kernel.org, netdev@vger.kernel.org
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120819064429.GA3252@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 18 Aug 2012 23:44:29 -0700
Greg KH <gregkh@linuxfoundation.org> wrote:

> On Sun, Aug 19, 2012 at 02:27:12PM -0400, Huang Shijie wrote:
> > --- a/include/linux/tty.h
> > +++ b/include/linux/tty.h
> > @@ -43,6 +43,7 @@
> >  #include <linux/tty_driver.h>
> >  #include <linux/tty_ldisc.h>
> >  #include <linux/mutex.h>
> > +#include <linux/serial.h>
> >  
> >  
> >  
> > @@ -513,6 +514,12 @@ static inline struct tty_port *tty_port_get(struct tty_port *port)
> >  	return port;
> >  }
> >  
> > +/* If the cts flow control is enabled, return true. */
> > +static inline bool tty_port_cts_enabled(struct tty_port *port)
> > +{
> > +	return port->flags & ASYNC_CTS_FLOW;
> > +}
> > +
> 
> The fact that you have to add serial.h to this file kind of implies that
> this function shouldn't be here, right?
> 
> How about serial.h instead?  Not all tty drivers are serial drivers :)

tty_port is tty generic so possibly if there is a generic helper the
flags and helper should likewise be this way.

As it stands at the moment ASYNC_CTS_FLOW is a convention a few drivers
use. So calling it tty_port_xxx is going to misleading.

Alan
