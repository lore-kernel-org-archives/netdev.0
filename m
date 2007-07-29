From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [linux-usb-devel] [PATCH] USB Pegasus driver - avoid a potential NULL pointer dereference.
Date: Sun, 29 Jul 2007 10:49:26 +0200
Message-ID: <200707291049.26619.oliver@neukum.org>
References: <200707290019.02591.jesper.juhl@gmail.com> <a781481a0707281637n5b123e4aib46c4e4b009b0018@mail.gmail.com> <9a8748490707281655u66e50bbfqba58687b579a85fe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Jesper Juhl" <jesper.juhl@gmail.com>,
	"Satyam Sharma" <satyam.sharma@gmail.com>,
	Greg Kroah-Hartman <greg@kroah.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Petko Manolov <petkan@users.sourceforge.net>
To: linux-usb-devel@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761128AbXG2Irp@vger.kernel.org>
In-Reply-To: <9a8748490707281655u66e50bbfqba58687b579a85fe@mail.gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Sonntag 29 Juli 2007 schrieb Jesper Juhl:
> On 29/07/07, Satyam Sharma <satyam.sharma@gmail.com> wrote:
> > Hi,
> >
> > On 7/29/07, Jesper Juhl <jesper.juhl@gmail.com> wrote:
> > > Hello,
> > >
> > > This patch makes sure we don't dereference a NULL pointer in
> > > drivers/net/usb/pegasus.c::write_bulk_callback() in the initial
> > > struct net_device *net = pegasus->net; assignment.
> > > The existing code checks if 'pegasus' is NULL and bails out if
> > > it is, so we better not touch that pointer until after that check.
> > > [...]
> > > diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
> > > index a05fd97..04cba6b 100644
> > > --- a/drivers/net/usb/pegasus.c
> > > +++ b/drivers/net/usb/pegasus.c
> > > @@ -768,11 +768,13 @@ done:
> > >  static void write_bulk_callback(struct urb *urb)
> > >  {
> > >         pegasus_t *pegasus = urb->context;
> > > -       struct net_device *net = pegasus->net;
> > > +       struct net_device *net;
> > >
> > >         if (!pegasus)
> > >                 return;
> > >
> > > +       net = pegasus->net;
> > > +
> > >         if (!netif_device_present(net) || !netif_running(net))
> > >                 return;
> >
> > Is it really possible that we're called into this function with
> > urb->context == NULL? If not, I'd suggest let's just get rid of
> > the check itself, instead.
> >
> I'm not sure. I am not very familiar with this code. I just figured
> that moving the assignment is potentially a little safer and it is
> certainly no worse than the current code, so that's a safe and
> potentially benneficial change. Removing the check may be safe but I'm
> not certain enough to make that call...

pegasus == NULL there would be a kernel bug. Silently ignoring
it, like the code now wants to do is bad. As the oops has never been
reported, I figure turning it into an explicit debugging test is overkill,
so removal seems to be the best option.

	Regards
		Oliver
