From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next 1/2] r8169: enable ALDPS for power saving
Date: Tue, 23 Oct 2012 10:24:39 +0800
Message-ID: <D81B36B929404E28AE7007B7E21B9D46@realtek.com.tw>
References: <1350893153-18320-1-git-send-email-hayeswang@realtek.com> <20121022192748.GA16370@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121022192748.GA16370@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Tuesday, October 23, 2012 3:28 AM
> To: Hayeswang
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; 
> jean@google.com
> Subject: Re: [PATCH net-next 1/2] r8169: enable ALDPS for power saving
> 
[...]
> > @@ -687,6 +687,7 @@ enum features {
> >  	RTL_FEATURE_WOL		= (1 << 0),
> >  	RTL_FEATURE_MSI		= (1 << 1),
> >  	RTL_FEATURE_GMII	= (1 << 2),
> > +	RTL_FEATURE_EXTENDED	= (1 << 3),
> 
> Is there a specific reason why it is not named RTL_FEATURE_ALDPS ?
> 
> RTL_FEATURE_EXTENDED is anything but enlightning.
> 

The flag is determined if the firmware is loaded. It doesn't mean to enable
ALDPS. Besides ALDPS, the firmware includes the other features about power
saving, performance, hw behavior, and so on. Thus, I think it  is the extended
feature. Any suggestion?

[...]
> > @@ -6391,6 +6433,8 @@ static void 
> rtl8169_net_suspend(struct net_device *dev)
> >  {
> >  	struct rtl8169_private *tp = netdev_priv(dev);
> >  
> > +	tp->features &= ~RTL_FEATURE_EXTENDED;
> > +
> 
> The commit message does not explain this part.
> 
> What are you trying to achieve ?

I don't sure if the firmware code still exists and works after hibernation. I
clear the flag for safe. It would be set again after loading firmware. It is
used to make sure to enable ALDPS with firmware.

> 
> After this patch the driver would look like:
> 1. disable ALDPS before setting firmware (unmodified by patch)
>    RTL_GIGA_MAC_VER_29 "RTL8105e"
>    RTL_GIGA_MAC_VER_30 "RTL8105e"
>    RTL_GIGA_MAC_VER_37 "RTL8402"
>    RTL_GIGA_MAC_VER_39 "RTL8106e"
> 
> 2. apply_firmware (unmodified by patch)
>    RTL_GIGA_MAC_VER_25 "RTL8168d/8111d"
>    RTL_GIGA_MAC_VER_26 "RTL8168d/8111d"
>    RTL_GIGA_MAC_VER_29 "RTL8105e"
>    RTL_GIGA_MAC_VER_30 "RTL8105e"
>    RTL_GIGA_MAC_VER_32 "RTL8168e/8111e"
>    RTL_GIGA_MAC_VER_33 "RTL8168e/8111e"
>    RTL_GIGA_MAC_VER_34 "RTL8168evl/8111evl"
>    RTL_GIGA_MAC_VER_35 "RTL8168f/8111f"
>    RTL_GIGA_MAC_VER_36 "RTL8168f/8111f"
>    RTL_GIGA_MAC_VER_37 "RTL8402"
>    RTL_GIGA_MAC_VER_38 "RTL8411"
>    RTL_GIGA_MAC_VER_39 "RTL8106e"
>    RTL_GIGA_MAC_VER_40 "RTL8168g/8111g"
> 
> 3. enable ALDPS after firmware
>    RTL_GIGA_MAC_VER_34 "RTL8168evl/8111evl"
>    RTL_GIGA_MAC_VER_35 "RTL8168f/8111f"
>    RTL_GIGA_MAC_VER_36 "RTL8168f/8111f"
>    RTL_GIGA_MAC_VER_37 "RTL8402"
>    RTL_GIGA_MAC_VER_38 "RTL8411"
>    RTL_GIGA_MAC_VER_39 "RTL8106e"
>    RTL_GIGA_MAC_VER_40 "RTL8168g/8111g"
> 
> The disable/enable ALDPS code is not trivially balanced.
> 
> Do we exactly perform the required ALDPS operations ? Nothing more,
> nothing less ?
> 

Because the different design between the giga nic and 10/100M nic, the behavior
would be different. For example, you couldn't disable the ALDPS of the giga nic
directly just like the 10/100M (8136 series) one. The giga nic would disable
ALDPS automatically when loading firmware, but the 8136 series wouldn't.

Best Regards,
Hayes
