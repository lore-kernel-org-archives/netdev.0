From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCHv4 1/4] modem_shm: Add Modem Access Framework
Date: Mon, 1 Oct 2012 08:59:40 -0700
Message-ID: <20121001155940.GA1957@kroah.com>
References: <1348819504-1303-1-git-send-email-arun.murthy@stericsson.com>
 <1348819504-1303-2-git-send-email-arun.murthy@stericsson.com>
 <20120928160045.GD2625@kroah.com>
 <F45880696056844FA6A73F415B568C695B6962C153@EXDCVYMBSTM006.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"alan@lxorguk.ukuu.org.uk" <alan@lxorguk.ukuu.org.uk>
To: Arun MURTHY <arun.murthy@stericsson.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <F45880696056844FA6A73F415B568C695B6962C153@EXDCVYMBSTM006.EQ1STM.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 01, 2012 at 07:30:38AM +0200, Arun MURTHY wrote:
> > On Fri, Sep 28, 2012 at 01:35:01PM +0530, Arun Murthy wrote:
> > > +#include <linux/module.h>
> > > +#include <linux/slab.h>
> > > +#include <linux/err.h>
> > > +#include <linux/printk.h>
> > > +#include <linux/modem_shm/modem.h>
> > > +
> > > +static struct class *modem_class;
> > 
> > What's wrong with a bus_type instead?
> 
> Can I know the advantage of using bus_type over class?

You have devices living on a bus, and it's much more descriptive than a
class (which we are going to eventually get rid of one of these
days...).

Might I ask why you choose a class over a bus_type?

> > > +int modem_release(struct modem_desc *mdesc) {
> > > +	if (!mdesc->release)
> > > +		return -EFAULT;
> > > +
> > > +	if (modem_is_requested(mdesc)) {
> > > +		atomic_dec(&mdesc->mclients->cnt);
> > > +		if (atomic_read(&mdesc->use_cnt) == 1) {
> > > +			mdesc->release(mdesc);
> > > +			atomic_dec(&mdesc->use_cnt);
> > > +		}
> > 
> > Eeek, why aren't you using the built-in reference counting that the struct
> > device provided to you, and instead are rolling your own?  This happens in
> > many places, why?
> 
> My usage of counters over here is for each modem there are many clients.
> Each of the clients will have a ref to modem_desc. Each of them use this for
> requesting and releasing the modem. One counter for tracking the request
> and release for each client which is done by variable 'cnt' in struct clients.
> The counter use_cnt is used for tracking the modem request/release irrespective
> of the clients and counter cli_cnt is used for restricting the modem_get to
> the no of clients defined in no_clients.
> 
> So totally 3 counter one for restricting the usage of modem_get by clients,
> second for restricting modem request/release at top level, and 3rd for
> restricting modem release/request for per client per modem basis.
> 
> Can you let me know if the same can be achieved by using built-in ref
> counting?

Yes, because you don't need all of those different levels, just stick
with one and you should be fine. :)

thanks,

greg k-h
