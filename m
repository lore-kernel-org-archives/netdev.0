From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next 1/3] r8152: separate USB_RX_EARLY_AGG
Date: Thu, 12 Feb 2015 02:36:17 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2EE92DB@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-137-Taiwan-albertk@realtek.com>
 <1394712342-15778-138-Taiwan-albertk@realtek.com>
 <54DB5E94.6010101@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54DB5E94.6010101@cogentembedded.com>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sergei Shtylyov [mailto:sergei.shtylyov@cogentembedded.com] 
[...]
> > +	ocp_data = tp->coalesce / 8;
> 
>     Why not do it in the initializer?

This is for patch #3. The patch #3 would use this function.
The unit of the relative setting from the ethtool is 1 us.
However, the unit for the hw is 8 us. Therefore, I save the
value with the unit of 1 us, and transfer it to the unit of
the hw when setting.

> > +	ocp_write_word(tp, MCU_TYPE_USB, USB_RX_EARLY_TIMEOUT, ocp_data);
> > +}
> > +
> > +static void r8153_set_rx_early_size(struct r8152 *tp)
> > +{
> > +	struct net_device *dev = tp->netdev;
> 
>     Not sure you actually need this variable.

If I replace dev->mtu with tp->netdev->mtu, the line would
more than 80 characters. This is used to avoid it. Should
I remove it?

> > +	u32 ocp_data;
> > +
> > +	ocp_data = (agg_buf_sz - dev->mtu - VLAN_ETH_HLEN - VLAN_HLEN) / 4;
> 
>     Why not in initializer?

This is for patch #2. The patch #2 would use this function.
It has to be re-calculated when the mtu is changed, or the
function is called when the linking status changes to ON.

> > +	ocp_write_word(tp, MCU_TYPE_USB, USB_RX_EARLY_SIZE, ocp_data);
> >   }
> [...]
> > @@ -3911,6 +3907,13 @@ static int rtl8152_probe(struct 
> usb_interface *intf,
> >   	tp->mii.reg_num_mask = 0x1f;
> >   	tp->mii.phy_id = R8152_PHY_ID;
> >
> > +	if (udev->speed == USB_SPEED_SUPER)
> > +		tp->coalesce = COALESCE_SUPER;
> > +	else if (udev->speed == USB_SPEED_HIGH)
> > +		tp->coalesce = COALESCE_HIGH;
> > +	else
> > +		tp->coalesce = COALESCE_SLOW;
> 
>     This is asking to be a *switch* statement.

Excuse me. I don't understand what you mean.
The usb speed is determined when the device is plugged on
the usb host controller or usb hub. The usb speed wouldn't
chage unless you unplug the device and plug it to another
port with different usb speed. Therefore, I provide different
default values for different usb speed.
 
Best Regards,
Hayes
