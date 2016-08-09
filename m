From: Andreas Werner <andreas.werner@men.de>
Subject: Re: [PATCH RESEND] net: can: Introduce MEN 16Z192-00 CAN controller
 driver
Date: Tue, 9 Aug 2016 08:11:21 +0200
Message-ID: <20160809061121.GD1733@awelinux>
References: <20160726091555.GA26227@awelinux>
 <20160808035814.ulqx4hnbtkkd2iko@f1.synalogic.ca>
 <20160808072620.GA5749@awelinux>
 <20160809032355.fzbdpudsqg2bdn27@f1.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andreas Werner <andreas.werner@men.de>, <wg@grandegger.com>,
	<mkl@pengutronix.de>, <linux-can@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<davem@davemloft.net>, <jthumshirn@suse.de>, <andy@wernerandy.de>
To: Benjamin Poirier <benjamin.poirier@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160809032355.fzbdpudsqg2bdn27@f1.synalogic.ca>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 08, 2016 at 08:23:55PM -0700, Benjamin Poirier wrote:
> On 2016/08/08 09:26, Andreas Werner wrote:
> [...]
> > > > +
> > > > +	if (cf->can_dlc > 0)
> > > > +		data[0] = be32_to_cpup((__be32 *)(cf->data));
> > > > +	if (cf->can_dlc > 3)
> > > > +		data[1] = be32_to_cpup((__be32 *)(cf->data + 4));
> > > > +
> > > > +	writel(id, &cf_buf->can_id);
> > > > +	writel(cf->can_dlc, &cf_buf->length);
> > > > +
> > > > +	if (!(cf->can_id & CAN_RTR_FLAG)) {
> > > > +		writel(data[0], &cf_buf->data[0]);
> > > > +		writel(data[1], &cf_buf->data[1]);
> > > > +
> > > > +		stats->tx_bytes += cf->can_dlc;
> > > > +	}
> > > > +
> > > > +	/* be sure everything is written to the
> > > > +	 * device before acknowledge the data.
> > > > +	 */
> > > > +	mmiowb();
> > > > +
> > > > +	/* trigger the transmission */
> > > > +	men_z192_ack_tx_pkg(priv, 1);
> > > > +
> > > > +	stats->tx_packets++;
> > > > +
> > > > +	kfree_skb(skb);
> > > 
> > > What prevents the skb data to be freed/reused before the device has
> > > accessed it?
> 
> I'm sorry, I hadn't realized that all of the data (all 8 bytes of it!)
> is written directly to the device. I was thinking about ethernet devices
> that dma packet data.

Ah ok :-)
I thought you just want me to free the skb earlier.

Regards
Andy
