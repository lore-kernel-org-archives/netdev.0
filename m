From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH net] ethernet: xircom: small clean up in
 setup_xirc2ps_cs()
Date: Mon, 21 Aug 2017 17:56:30 +0300
Message-ID: <20170821145630.uu7kysb54gk3gea4@mwanda>
References: <20170821094730.ydm2xwsqbkyadybi@mwanda>
 <063D6719AE5E284EB5DD2968C1650D6DD005CC34@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarod Wilson <jarod@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        Ilya Matveychikov <matvejchikov@gmail.com>,
        Baoquan He <bhe@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD005CC34@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 21, 2017 at 02:52:34PM +0000, David Laight wrote:
> From: Dan Carpenter
> > Sent: 21 August 2017 10:48
> > The get_options() function takes the whole ARRAY_SIZE().  It doesn't
> > matter here because we don't use more than 7 elements.
> > 
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> > 
> > diff --git a/drivers/net/ethernet/xircom/xirc2ps_cs.c b/drivers/net/ethernet/xircom/xirc2ps_cs.c
> > index f71883264cc0..fd5288ff53b5 100644
> > --- a/drivers/net/ethernet/xircom/xirc2ps_cs.c
> > +++ b/drivers/net/ethernet/xircom/xirc2ps_cs.c
> > @@ -1781,7 +1781,7 @@ static int __init setup_xirc2ps_cs(char *str)
> >  	 */
> >  	int ints[10] = { -1 };
> > 
> > -	str = get_options(str, 9, ints);
> > +	str = get_options(str, ARRAY_SIZE(ints), ints);
> > 
> >  #define MAYBE_SET(X,Y) if (ints[0] >= Y && ints[Y] != -1) { X = ints[Y]; }
> >  	MAYBE_SET(if_port, 3);
> 
> That code looks very dubious to me.
> It looks as though it expects all of the ints[] array to be initialised
> to -1, not just the first element.

I'm pretty sure you're right and I thought about changing it when I sent
the patch but it doesn't matter.  It's not required to initialize that
code anyway because either get_options() will initialize it or it won't
be used.

regards,
dan carpenter
