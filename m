From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH net 1/2] r8152: add pre_reset and post_reset
Date: Tue, 28 Jul 2015 14:05:37 +0200
Message-ID: <1438085137.1787.2.camel@suse.com>
References: <1394712342-15778-156-Taiwan-albertk@realtek.com>
	 <1394712342-15778-157-Taiwan-albertk@realtek.com>
	 <1438073562.11934.2.camel@suse.com>
	 <0835B3720019904CB8F7AA43166CEEB2F3C3EC@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2F3C3EC@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-07-28 at 09:52 +0000, Hayes Wang wrote:
> Oliver Neukum [mailto:oneukum@suse.com]
> > Sent: Tuesday, July 28, 2015 4:53 PM
> [...]
> > > +		return 0;
> > > +
> > > +	netdev = tp->netdev;
> > > +	if (!netif_running(netdev))
> > > +		return 0;
> > > +
> > > +	ret = usb_autopm_get_interface(intf);
> > > +	if (ret < 0)
> > > +		return ret;
> > 
> > What sense does this make?
> > 
> [...]
> > > +		return 0;
> > > +
> > > +	netdev = tp->netdev;
> > > +	if (!netif_running(netdev))
> > > +		return 0;
> > > +
> > > +	ret = usb_autopm_get_interface(intf);
> > 
> > The device will be awake.
> 
> I don't sure if the device would be in runtimesuspend, so I wake it up by myself.
> I think you mean I don't have to do this. I would remove them and resend the
> patch. Thanks.

Usbcore will resume the device.

	HTH
		Oliver

     A. 
        /* Prevent autosuspend during the reset */
        usb_autoresume_device(udev);

        if (config) {
                for (i = 0; i < config->desc.bNumInterfaces; ++i) {
                        struct usb_interface *cintf = config->interface[i];
                        struct usb_driver *drv;
                        int unbind = 0;

                        if (cintf->dev.driver) {
                                drv = to_usb_driver(cintf->dev.driver);
                                if (drv->pre_reset && drv->post_reset)
                                        unbind = (drv->pre_reset)(cintf);
