From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH net v2 2/2] r8152: reset device when tx timeout
Date: Tue, 28 Jul 2015 14:14:05 +0200
Message-ID: <1438085645.1787.4.camel@suse.com>
References: <1394712342-15778-156-Taiwan-albertk@realtek.com>
	 <1394712342-15778-159-Taiwan-albertk@realtek.com>
	 <1394712342-15778-161-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:42999 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752085AbbG1MPQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jul 2015 08:15:16 -0400
In-Reply-To: <1394712342-15778-161-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-07-28 at 20:08 +0800, Hayes Wang wrote:
>  static void rtl8152_tx_timeout(struct net_device *netdev)
>  {
>         struct r8152 *tp = netdev_priv(netdev);
> -       int i;
>  
>         netif_warn(tp, tx_err, netdev, "Tx timeout\n");
> -       for (i = 0; i < RTL8152_MAX_TX; i++)
> -               usb_unlink_urb(tp->tx_info[i].urb);
> +
> +       usb_queue_reset_device(tp->intf);
> +       cancel_delayed_work(&tp->schedule);

Sorry to bother you again, but this looks wrong.
You want to cancel first. There is no point in
running any work before the reset is done. It will
undo any progress anyway.

	Regards
		Oliver
