From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH net v2 2/2] r8152: reset device when tx timeout
Date: Tue, 28 Jul 2015 14:58:37 +0200
Message-ID: <1438088317.1787.5.camel@suse.com>
References: <1394712342-15778-156-Taiwan-albertk@realtek.com>
	 <1394712342-15778-159-Taiwan-albertk@realtek.com>
	 <1394712342-15778-161-Taiwan-albertk@realtek.com>
	 <1438085645.1787.4.camel@suse.com>
	 <0835B3720019904CB8F7AA43166CEEB2F3C538@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2F3C538@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-07-28 at 12:31 +0000, Hayes Wang wrote:
> Oliver Neukum [mailto:oneukum@suse.com]
> > Sent: Tuesday, July 28, 2015 8:14 PM
> [...]
> > >  static void rtl8152_tx_timeout(struct net_device *netdev)  {
> > >         struct r8152 *tp = netdev_priv(netdev);
> > > -       int i;
> > >
> > >         netif_warn(tp, tx_err, netdev, "Tx timeout\n");
> > > -       for (i = 0; i < RTL8152_MAX_TX; i++)
> > > -               usb_unlink_urb(tp->tx_info[i].urb);
> > > +
> > > +       usb_queue_reset_device(tp->intf);
> > > +       cancel_delayed_work(&tp->schedule);
> > 
> > Sorry to bother you again, but this looks wrong.
> > You want to cancel first. There is no point in running any work before the reset is
> > done. It will undo any progress anyway.
> 
> Excuse me. Do you mean I don't need cancel the other work because it wouldn't be
> run before the reset is finished?

No, whatever the other work will do, the reset will undo.

	Regards
		Oliver
