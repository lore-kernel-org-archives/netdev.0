From: Mark Einon <mark.einon@gmail.com>
Subject: Re: [PATCH 4/8] staging: et131x: Use for loop to initialise
 contiguous macstat registers to zero
Date: Thu, 21 Aug 2014 11:05:14 +0100
Message-ID: <20140821100514.GD2230@msilap.einon.net>
References: <1408573078-9320-1-git-send-email-mark.einon@gmail.com>
 <1408573078-9320-5-git-send-email-mark.einon@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1747D483@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1747D483@AcuExch.aculab.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 21, 2014 at 08:40:20AM +0000, David Laight wrote:
> From: Mark Einon
> > Replace a long list of contiguous writel() calls with a for loop iterating
> > over the same address values.
> > 
> > Also remove redundant comments on the macstat registers, the variable names
> > are good enough.
> ...
> > -	writel(0, &macstat->txrx_0_64_byte_frames);
> ...
> > -	writel(0, &macstat->carry_reg2);
> > +	/* initialize all the macstat registers to zero on the device  */
> > +	for (reg = &macstat->txrx_0_64_byte_frames;
> > +	     reg <= &macstat->carry_reg2; reg++)
> > +		writel(0, reg);
> ...
> >  struct macstat_regs {			/* Location: */
> >  	u32 pad[32];			/*  0x6000 - 607C */
> > 
> > -	/* Tx/Rx 0-64 Byte Frame Counter */
> > +	/* counters */
> >  	u32 txrx_0_64_byte_frames;	/*  0x6080 */
> > -
> > -	/* Tx/Rx 65-127 Byte Frame Counter */
> >  	u32 txrx_65_127_byte_frames;	/*  0x6084 */
> 
> I think it would be best to also convert the stats counters to an array.

Hi David, thanks for the review.

There's other code that accesses these registers individually, taking into
account carries - so I don't think using an array would change much, as
we'd still need a way of identifying individual indices.

Cheers,

Mark
