From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH v3] can: Add driver for esd CAN-USB/2 device
Date: Fri, 28 May 2010 17:26:00 +0200
Message-ID: <201005281726.00855.oneukum@suse.de>
References: <201005261114.03214.matthias.fuchs@esd.eu> <201005261547.34596.oneukum@suse.de> <201005281619.33845.matthias.fuchs@esd.eu>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Socketcan-core@lists.berlios.de,
	linux-usb@vger.kernel.org
To: Matthias Fuchs <matthias.fuchs@esd.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:36838 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750929Ab0E1PZy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 May 2010 11:25:54 -0400
In-Reply-To: <201005281619.33845.matthias.fuchs@esd.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Freitag, 28. Mai 2010 16:19:33 schrieb Matthias Fuchs:
> On Wednesday 26 May 2010 15:47, Oliver Neukum wrote:
> > Am Mittwoch, 26. Mai 2010 11:14:03 schrieb Matthias Fuchs:
> > > +       netdev->trans_start = jiffies;
> > > +
> > > +       /* Slow down tx path */
> > > +       if (atomic_read(&priv->active_tx_jobs) >= MAX_TX_URBS)
> > > +               netif_stop_queue(netdev);
> > 
> > Where is the queue started again?
> > 
> > 	Regards
> > 		Oliver
> 
> This is done in the ack-patch for sent messages:
> 
> static void esd_usb2_tx_done_msg(struct esd_usb2_net_priv *priv,
> 				 struct esd_usb2_msg *msg)
> {
> ...
> 	atomic_dec(&priv->active_tx_jobs);
> 
> 	netif_wake_queue(netdev);
> }

Oh, I see. I am afraid this is a race. You have no guarantee that
esd_usb2_tx_done_msg() runs after you stop the queue. If you do
it that way you must stop the queue before you submit the URB
due to which you want to stop it (and do the error handling)

	Regards
		Oliver
