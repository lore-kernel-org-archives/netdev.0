From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: Re: [PATCH v3 4/4] can: kvaser_usb: Add support for the Usbcan-II
 family
Date: Fri, 9 Jan 2015 05:06:57 +0200
Message-ID: <20150109030657.GA1791@vivalin-002>
References: <20141223154654.GB6460@vivalin-002>
 <20150105174910.GA6304@linux>
 <20150105175206.GB6304@linux>
 <20150105175713.GC6304@linux>
 <20150105183131.GD6304@linux>
 <54AE6FC1.6050007@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	"David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54AE6FC1.6050007@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 08, 2015 at 12:53:37PM +0100, Marc Kleine-Budde wrote:
> On 01/05/2015 07:31 PM, Ahmed S. Darwish wrote:
> > 

[...]

> > 
> > 		cf->can_id |= CAN_ERR_CRTL;
> > 		cf->data[1] = CAN_ERR_CRTL_RX_OVERFLOW;
> > 
> > 		stats->rx_over_errors++;
> > 		stats->rx_errors++;
> > 
> > 		netif_rx(skb);
> > 
> > 		stats->rx_packets++;
> > 		stats->rx_bytes += cf->can_dlc;
> 
> Another patch would be not to touch cf after netif_rx(), please move the stats handling before calling netif_rx(). Same applies to the kvaser_usb_rx_can_msg() function.
> 

BTW, is it guaranteed from the SocketCAN stack that netif_rx()
will never return NET_RX_DROPPED? Because if no guarantee
exists, I guess below fragment cannot be completely correct?

        stats->rx_packets++;
        stats->rx_bytes += cf->can_dlc;
        netif_rx(skb);

On the other hand, I don't see evan a single CAN driver checking
netif_rx() return value, so maybe such a check is an overkill...

Thanks,
Darwish
