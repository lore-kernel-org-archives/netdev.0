From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 net-next 1/2] net: dsa: lan9303: Add port_fast_age
 and port_fdb_dump methods
Date: Thu, 19 Oct 2017 15:15:49 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD009C922@AcuExch.aculab.com>
References: <20171019121015.7395-1-privat@egil-hjelmeland.no>
 <20171019121015.7395-2-privat@egil-hjelmeland.no>
 <87mv4nw869.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <20171019141505.GA14840@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Andrew Lunn' <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171019141505.GA14840@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Lunn
> Sent: 19 October 2017 15:15
> > > +/* Clear learned (non-static) entry on given port */
> > > +static void alr_loop_cb_del_port_learned(struct lan9303 *chip, u32 dat0,
> > > +					 u32 dat1, int portmap, void *ctx)
> > > +{
> > > +	int *port = ctx;
> >
> > You can get the value directly to make the line below more readable:
> >
> >     int port = *(int *)ctx;
> 
> You have to be a bit careful with this. You often see people
> submitting patches taking away casts for void * pointers.
> If they do that here, it should at least not compile...
> 
> So maybe do it in two steps?
> 
>    int * pport = ctx;
>    int port = *pport;

IMHO it is best to define a struct for the 'ctx and then do:
	..., void *v_ctx)
{
	foo_ctx *ctx = v_ctx;
	int port = ctx->port;

That stops anyone having to double-check that the *(int *)
is operating on a pointer to an integer of the correct size.

One of the syntax checkers probably ought to generate a warning
for *(integer_type *)foo since it is often a bug.

	David
