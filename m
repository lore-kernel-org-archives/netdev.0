From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 1/3] r8152: separate USB_RX_EARLY_AGG
Date: Thu, 12 Feb 2015 14:37:17 +0300
Message-ID: <54DC906D.60009@cogentembedded.com>
References: <1394712342-15778-137-Taiwan-albertk@realtek.com> <1394712342-15778-138-Taiwan-albertk@realtek.com> <54DB5E94.6010101@cogentembedded.com> <0835B3720019904CB8F7AA43166CEEB2EE92DB@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2EE92DB@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 2/12/2015 5:36 AM, Hayes Wang wrote:

> [...]
>>> +	ocp_data = tp->coalesce / 8;

>>      Why not do it in the initializer?

> This is for patch #3. The patch #3 would use this function.

    The new function is already called in this patch.

> The unit of the relative setting from the ethtool is 1 us.
> However, the unit for the hw is 8 us. Therefore, I save the
> value with the unit of 1 us, and transfer it to the unit of
> the hw when setting.

    You're replying to the question I didn't ask. I was just suggesting:

	u32 ocp_data = tp->coalesce / 8;

>>> +	ocp_write_word(tp, MCU_TYPE_USB, USB_RX_EARLY_TIMEOUT, ocp_data);

    ... if you don't want to pass 'tp->coalesce / 8' directly here.

>>> +}
>>> +
>>> +static void r8153_set_rx_early_size(struct r8152 *tp)
>>> +{
>>> +	struct net_device *dev = tp->netdev;

>>      Not sure you actually need this variable.

> If I replace dev->mtu with tp->netdev->mtu, the line would
> more than 80 characters. This is used to avoid it. Should
> I remove it?

    OK, you can keep it.

>>> +	u32 ocp_data;
>>> +
>>> +	ocp_data = (agg_buf_sz - dev->mtu - VLAN_ETH_HLEN - VLAN_HLEN) / 4;

>>      Why not in initializer?

> This is for patch #2. The patch #2 would use this function.

    The new function is again used in this patch already.

> It has to be re-calculated when the mtu is changed, or the
> function is called when the linking status changes to ON.

    You're again replying to the question I didn't ask. I was just suggesting:

	u32 ocp_data = (agg_buf_sz - dev->mtu - VLAN_ETH_HLEN - VLAN_HLEN) / 4;

>>> +	ocp_write_word(tp, MCU_TYPE_USB, USB_RX_EARLY_SIZE, ocp_data);

    ... if you don't want to pass that expression directly here.

[...]
>>> @@ -3911,6 +3907,13 @@ static int rtl8152_probe(struct
>>> usb_interface *intf,
>>>    	tp->mii.reg_num_mask = 0x1f;
>>>    	tp->mii.phy_id = R8152_PHY_ID;
>>>
>>> +	if (udev->speed == USB_SPEED_SUPER)
>>> +		tp->coalesce = COALESCE_SUPER;
>>> +	else if (udev->speed == USB_SPEED_HIGH)
>>> +		tp->coalesce = COALESCE_HIGH;
>>> +	else
>>> +		tp->coalesce = COALESCE_SLOW;

>>      This is asking to be a *switch* statement.

> Excuse me. I don't understand what you mean.

	switch (udev->speed) {
	case USB_SPEED_SUPER:
		tp->coalesce = COALESCE_SUPER;
		break;
	case USB_SPEED_HIGH:
		tp->coalesce = COALESCE_HIGH;
		break;
	default:
		tp->coalesce = COALESCE_SLOW;
	}

> The usb speed is determined when the device is plugged on
> the usb host controller or usb hub. The usb speed wouldn't
> chage unless you unplug the device and plug it to another
> port with different usb speed. Therefore, I provide different
> default values for different usb speed.

    I didn't ask for explanations here either. :-)

> Best Regards,
> Hayes

WBR, Sergei
