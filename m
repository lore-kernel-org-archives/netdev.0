From: <Mario_Limonciello@Dell.com>
Subject: RE: [PATCH v2] r8152: Add support for setting MAC to system's
 Auxiliary MAC address
Date: Fri, 3 Jun 2016 15:08:14 +0000
Message-ID: <a13b06db9383446d8e5eea460c274ee4@ausx13mpc124.AMER.DELL.COM>
References: <1464886687-16284-1-git-send-email-mario_limonciello@dell.com>
 <1464886687-16284-2-git-send-email-mario_limonciello@dell.com>
 <0835B3720019904CB8F7AA43166CEEB2FED9B5@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, <pali.rohar@gmail.com>,
	<anthony.wong@canonical.com>, <gregkh@linuxfoundation.org>
To: <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2FED9B5@RTITMBSV03.realtek.com.tw>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Hayes Wang [mailto:hayeswang@realtek.com]
> Sent: Friday, June 3, 2016 4:44 AM
> To: Limonciello, Mario <Mario_Limonciello@Dell.com>
> Cc: LKML <linux-kernel@vger.kernel.org>; Netdev
> <netdev@vger.kernel.org>; Linux USB <linux-usb@vger.kernel.org>;
> pali.rohar@gmail.com; anthony.wong@canonical.com; Greg KH
> <gregkh@linuxfoundation.org>
> Subject: RE: [PATCH v2] r8152: Add support for setting MAC to system's
> Auxiliary MAC address
> 
> Mario Limonciello [mailto:mario_limonciello@dell.com]
> > Sent: Friday, June 03, 2016 12:58 AM
> [...]
> > @@ -500,6 +502,7 @@ enum rtl8152_flags {
> >  	SELECTIVE_SUSPEND,
> >  	PHY_RESET,
> >  	SCHEDULE_NAPI,
> > +	MAC_PASSTHRU = 0,
> 
> I don't think you have to give this a value.
> 
> >  };
> >
> [...]
> >  static int set_ethernet_addr(struct r8152 *tp)
> >  {
> >  	struct net_device *dev = tp->netdev;
> > @@ -1041,6 +1088,10 @@ static int set_ethernet_addr(struct r8152 *tp)
> >  	else
> >  		ret = pla_ocp_read(tp, PLA_BACKUP, 8, sa.sa_data);
> >
> > +	/* if system provides auxiliary MAC address */
> > +	if (get_auxiliary_addr(tp, &sa))
> > +		ret = 0;
> 
> It still has problem when tp->version == RTL_VER_01.
> First, you would read the current MAC address (MAC1) to sa.sa_data.
> Then sa.sa_data may be modified by MAC2 after get_auxiliary_addr().
> However, the MAC2 wouldn't be set to the device, because
> 
> 		if (tp->version == RTL_VER_01)
> 			ether_addr_copy(dev->dev_addr, sa.sa_data);
> 
> Therefore, you would find that dev_addr is MAC2, and the device
> uses MAC1.
> 
> Best Regards,
> Hayes
> 

Hayes,

>From the information that I got that this is only a valid thing to do on
RTL-8153-AD (when dock bit set), should this only match with 
tp->version  >= RTL_VER_03? 

How can I confirm that the chip is 8153-AD specifically?  I didn't see
something obvious in driver to tell this.

Thanks,
