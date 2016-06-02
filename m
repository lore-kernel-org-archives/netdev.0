From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH] r8152: Add support for setting MAC to system's Auxiliary MAC address
Date: Thu, 2 Jun 2016 06:10:26 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2FECCF4@RTITMBSV03.realtek.com.tw>
References: <1464817844-27206-1-git-send-email-mario_limonciello@dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Linux USB <linux-usb@vger.kernel.org>,
	"pali.rohar@gmail.com" <pali.rohar@gmail.com>,
	"anthony.wong@canonical.com" <anthony.wong@canonical.com>
To: Mario Limonciello <mario_limonciello@dell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464817844-27206-1-git-send-email-mario_limonciello@dell.com>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mario Limonciello [mailto:mario_limonciello@dell.com]
[...]
>  static int set_ethernet_addr(struct r8152 *tp)
>  {
>  	struct net_device *dev = tp->netdev;
> @@ -1041,6 +1075,9 @@ static int set_ethernet_addr(struct r8152 *tp)
>  	else
>  		ret = pla_ocp_read(tp, PLA_BACKUP, 8, sa.sa_data);
> 
> +	/* if system provides auxiliary MAC address */
> +	set_auxiliary_addr(&sa);
> +
>  	if (ret < 0) {
>  		netif_err(tp, probe, dev, "Get ether addr fail\n");
>  	} else if (!is_valid_ether_addr(sa.sa_data)) {

When tp->version == RTL_VER_01, you would have different MAC address
between SW and HW. You may use the MAC address from ACPI for dev_addr.
However, the device uses another one, because you don't set it to the device.

Best Regards,
Hayes
