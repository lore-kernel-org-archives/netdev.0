From: Olivier Sobrie <olivier@sobrie.be>
Subject: Re: [PATCH 04/11] hso: fix memory leak in hso_create_rfkill()
Date: Tue, 20 Jan 2015 16:10:39 +0100
Message-ID: <20150120151039.GB5681@hposo>
References: <1421756978-4093-1-git-send-email-olivier@sobrie.be>
 <1421756978-4093-2-git-send-email-olivier@sobrie.be>
 <1421756978-4093-3-git-send-email-olivier@sobrie.be>
 <1421756978-4093-4-git-send-email-olivier@sobrie.be>
 <1421756978-4093-5-git-send-email-olivier@sobrie.be>
 <1421759597.29486.22.camel@linux-0dmf.site>
Reply-To: Olivier Sobrie <olivier@sobrie.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Dumon <j.dumon@option.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1421759597.29486.22.camel@linux-0dmf.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 20, 2015 at 02:13:17PM +0100, Oliver Neukum wrote:
> On Tue, 2015-01-20 at 13:29 +0100, Olivier Sobrie wrote:
> > When the rfkill interface was created, a buffer containing the name
> > of the rfkill node was allocated. This buffer was never freed when the
> > device disappears.
> > 
> > To fix the problem, we put the name given to rfkill_alloc() in
> > the hso_net structure.
> > 
> > Signed-off-by: Olivier Sobrie <olivier@sobrie.be>
> > ---
> >  drivers/net/usb/hso.c | 12 +++---------
> >  1 file changed, 3 insertions(+), 9 deletions(-)
> > 
> > diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
> > index 470ef9e..a49ac2e 100644
> > --- a/drivers/net/usb/hso.c
> > +++ b/drivers/net/usb/hso.c
> > @@ -153,6 +153,7 @@ struct hso_net {
> >  	struct hso_device *parent;
> >  	struct net_device *net;
> >  	struct rfkill *rfkill;
> > +	char name[8];
> >  
> >  	struct usb_endpoint_descriptor *in_endp;
> >  	struct usb_endpoint_descriptor *out_endp;
> > @@ -2467,27 +2468,20 @@ static void hso_create_rfkill(struct hso_device *hso_dev,
> >  {
> >  	struct hso_net *hso_net = dev2net(hso_dev);
> >  	struct device *dev = &hso_net->net->dev;
> > -	char *rfkn;
> >  
> > -	rfkn = kzalloc(20, GFP_KERNEL);
> > -	if (!rfkn)
> > -		dev_err(dev, "%s - Out of memory\n", __func__);
> > -
> > -	snprintf(rfkn, 20, "hso-%d",
> > +	snprintf(hso_net->name, sizeof(hso_net->name), "hso-%d",
> >  		 interface->altsetting->desc.bInterfaceNumber);
> 
> That number is not unique. Indeed it will be identical for all devices.

Indeed. That should be corrected too.
Thank you,

Olivier
