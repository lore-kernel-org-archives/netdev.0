From: Stephen Hemminger <shemminger@osdl.org>
Subject: 8139cp NAPI race?
Date: Fri, 17 Oct 2003 10:26:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031017102622.19a8511f.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

If I read the documentation (and other drivers) the two lines
in 8139cp.c look backwards:

static int cp_rx_poll (struct net_device *dev, int *budget)
{
...
	/* if we did not reach work limit, then we're done with
	 * this round of polling
	 */
	if (rx_work) {
		if (cpr16(IntrStatus) & cp_rx_intr_mask)
			goto rx_status_loop;

<1>		cpw16_f(IntrMask, cp_intr_mask);   
<2>		netif_rx_complete(dev);

		return 0;	/* done */
	}

Isn't re-enable supposed to be after rx_complete to avoid races.
