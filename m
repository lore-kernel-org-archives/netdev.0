From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: RE: [PATCH v2] r8152: Add support for setting MAC to system's Auxiliary MAC address
Date: Fri, 3 Jun 2016 09:43:35 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2FED9B5@RTITMBSV03.realtek.com.tw>
References: <1464886687-16284-1-git-send-email-mario_limonciello@dell.com>
 <1464886687-16284-2-git-send-email-mario_limonciello@dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux USB <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"anthony.wong-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org" <anthony.wong-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
To: Mario Limonciello <mario_limonciello-8PEkshWhKlo@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1464886687-16284-2-git-send-email-mario_limonciello-8PEkshWhKlo@public.gmane.org>
Content-Language: zh-TW
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Mario Limonciello [mailto:mario_limonciello-8PEkshWhKlo@public.gmane.org]
> Sent: Friday, June 03, 2016 12:58 AM
[...]
> @@ -500,6 +502,7 @@ enum rtl8152_flags {
>  	SELECTIVE_SUSPEND,
>  	PHY_RESET,
>  	SCHEDULE_NAPI,
> +	MAC_PASSTHRU = 0,

I don't think you have to give this a value.

>  };
> 
[...]
>  static int set_ethernet_addr(struct r8152 *tp)
>  {
>  	struct net_device *dev = tp->netdev;
> @@ -1041,6 +1088,10 @@ static int set_ethernet_addr(struct r8152 *tp)
>  	else
>  		ret = pla_ocp_read(tp, PLA_BACKUP, 8, sa.sa_data);
> 
> +	/* if system provides auxiliary MAC address */
> +	if (get_auxiliary_addr(tp, &sa))
> +		ret = 0;

It still has problem when tp->version == RTL_VER_01.
First, you would read the current MAC address (MAC1) to sa.sa_data.
Then sa.sa_data may be modified by MAC2 after get_auxiliary_addr().
However, the MAC2 wouldn't be set to the device, because

		if (tp->version == RTL_VER_01)
			ether_addr_copy(dev->dev_addr, sa.sa_data);

Therefore, you would find that dev_addr is MAC2, and the device
uses MAC1.

Best Regards,
Hayes


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
