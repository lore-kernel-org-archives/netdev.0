From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2 1/4] can: kvaser_usb: Don't free packets when tight on
 URBs
Date: Wed, 24 Dec 2014 18:50:11 -0800
Message-ID: <20141225025011.GA10491@kroah.com>
References: <20141223154654.GB6460@vivalin-002>
 <20141224235644.GA3778@vivalin-002>
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
	Linux-stable <stable@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Ahmed S. Darwish" <darwish.07@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141224235644.GA3778@vivalin-002>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 25, 2014 at 01:56:44AM +0200, Ahmed S. Darwish wrote:
> From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
> 
> Flooding the Kvaser CAN to USB dongle with multiple reads and
> writes in high frequency caused seemingly-random panics in the
> kernel.
> 
> On further inspection, it seems the driver erroneously freed the
> to-be-transmitted packet upon getting tight on URBs and returning
> NETDEV_TX_BUSY, leading to invalid memory writes and double frees
> at a later point in time.
> 
> Note:
> 
> Finding no more URBs/transmit-contexts and returning NETDEV_TX_BUSY
> is a driver bug in and out of itself: it means that our start/stop
> queue flow control is broken.
> 
> This patch only fixes the (buggy) error handling code; the root
> cause shall be fixed in a later commit.
> 
> Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
> ---
>  drivers/net/can/usb/kvaser_usb.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
>  (Marc, Greg, I believe this should also be added to -stable?)


<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
for how to do this properly.

</formletter>
