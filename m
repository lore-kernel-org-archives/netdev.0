From: Matthias Fuchs <matthias.fuchs-iOnpLzIbIdM@public.gmane.org>
Subject: Re: [PATCH v3] can: Add driver for esd CAN-USB/2 device
Date: Fri, 28 May 2010 16:19:33 +0200
Message-ID: <201005281619.33845.matthias.fuchs@esd.eu>
References: <201005261114.03214.matthias.fuchs@esd.eu>
	<201005261547.34596.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <201005261547.34596.oneukum-l3A5Bk7waGM@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday 26 May 2010 15:47, Oliver Neukum wrote:
> Am Mittwoch, 26. Mai 2010 11:14:03 schrieb Matthias Fuchs:
> > +       netdev->trans_start = jiffies;
> > +
> > +       /* Slow down tx path */
> > +       if (atomic_read(&priv->active_tx_jobs) >= MAX_TX_URBS)
> > +               netif_stop_queue(netdev);
> 
> Where is the queue started again?
> 
> 	Regards
> 		Oliver

This is done in the ack-patch for sent messages:

static void esd_usb2_tx_done_msg(struct esd_usb2_net_priv *priv,
				 struct esd_usb2_msg *msg)
{
...
	atomic_dec(&priv->active_tx_jobs);

	netif_wake_queue(netdev);
}

Matthias
