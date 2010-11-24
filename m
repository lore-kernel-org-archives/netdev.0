From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH net-2.6] net, ppp: Report correct error code if unit
	allocation failed
Date: Wed, 24 Nov 2010 19:25:18 +0300
Message-ID: <20101124162518.GA6450@lenovo>
References: <20101123214344.GB1839@lenovo> <20101124124901.GA9268@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LNML <netdev@vger.kernel.org>, Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>, linux-ppp@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101124124901.GA9268@ff.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 24, 2010 at 12:49:01PM +0000, Jarek Poplawski wrote:
> On 2010-11-23 22:43, Cyrill Gorcunov wrote:
> > Allocating unit from ird might return several error codes
> > not only -EAGAIN, so it should not be changed and returned
> > precisely. Same time unit release procedure should be invoked
> > only if device is unregistering.
> 
> IMHO this unit release fix should be in a separate patch.
> 

 I thought about it, but still think it should be addressed at
same patch. Though if a separate would be preferred still --
I've no problem in making two patches instead.

> ...
> > @@ -2668,10 +2668,10 @@ static void ppp_shutdown_interface(struc
> >  		ppp->closing = 1;
> >  		ppp_unlock(ppp);
> >  		unregister_netdev(ppp->dev);
> > +		unit_put(&pn->units_idr, ppp->file.index);
> >  	} else
> >  		ppp_unlock(ppp);
> >  
> > -	unit_put(&pn->units_idr, ppp->file.index);
> >  	ppp->file.dead = 1;
> >  	ppp->owner = NULL;
> >  	wake_up_interruptible(&ppp->file.rwait);
> 
> Btw, it seems these last 3 lines could be moved similarly.

yup, at least ppp->file.dead and ppp->owner for sure, I wanted
make this patch 'unit' orientedc and do not touch anything aside,
it should be a separate change.

> 
> Jarek P.
>

Thanks for comments Jarek!
 
  Cyrill
