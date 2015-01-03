From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: Re: [PATCH] can: kvaser_usb: Don't free packets when tight on URBs
Date: Sat, 3 Jan 2015 16:34:42 +0200
Message-ID: <20150103143442.GA24998@Darwish.PC>
References: <20141223154654.GB6460@vivalin-002>
 <20150101135913.6205ce0e@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150101135913.6205ce0e@urahara>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 01, 2015 at 01:59:13PM -0800, Stephen Hemminger wrote:
> On Tue, 23 Dec 2014 17:46:54 +0200
> "Ahmed S. Darwish" <darwish.07@gmail.com> wrote:
> 
> >  	int ret = NETDEV_TX_OK;
> > +	bool kfree_skb_on_error = true;
> >  
> >  	if (can_dropped_invalid_skb(netdev, skb))
> >  		return NETDEV_TX_OK;
> > @@ -1336,6 +1337,7 @@ static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
> >  
> >  	if (!context) {
> >  		netdev_warn(netdev, "cannot find free context\n");
> > +		kfree_skb_on_error = false;
> >  		ret =  NETDEV_TX_BUSY;
> 
> You already have a flag value (ret == NETDEV_TX_BUSY), why
> not use that instead of introducing another variable?

Yes, that variable got implicitly removed in v2 patch 1/4.

Thanks,

--
Darwish
