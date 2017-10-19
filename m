From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next 1/2] net: dsa: lan9303: Add port_fast_age and
 port_fdb_dump methods
Date: Thu, 19 Oct 2017 16:15:05 +0200
Message-ID: <20171019141505.GA14840@lunn.ch>
References: <20171019121015.7395-1-privat@egil-hjelmeland.no>
 <20171019121015.7395-2-privat@egil-hjelmeland.no>
 <87mv4nw869.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87mv4nw869.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > +/* Clear learned (non-static) entry on given port */
> > +static void alr_loop_cb_del_port_learned(struct lan9303 *chip, u32 dat0,
> > +					 u32 dat1, int portmap, void *ctx)
> > +{
> > +	int *port = ctx;
> 
> You can get the value directly to make the line below more readable:
> 
>     int port = *(int *)ctx;

You have to be a bit careful with this. You often see people
submitting patches taking away casts for void * pointers.
If they do that here, it should at least not compile...

So maybe do it in two steps?

   int * pport = ctx;
   int port = *pport;

???
	Andrew
