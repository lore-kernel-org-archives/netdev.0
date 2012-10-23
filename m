From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 1/2] r8169: enable ALDPS for power saving
Date: Tue, 23 Oct 2012 21:31:46 +0200
Message-ID: <20121023193146.GA10463@electric-eye.fr.zoreil.com>
References: <1350893153-18320-1-git-send-email-hayeswang@realtek.com> <20121022192748.GA16370@electric-eye.fr.zoreil.com> <D81B36B929404E28AE7007B7E21B9D46@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: hayeswang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <D81B36B929404E28AE7007B7E21B9D46@realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hayeswang <hayeswang@realtek.com> :
[...]
> The flag is determined if the firmware is loaded. It doesn't mean to enable
> ALDPS. Besides ALDPS, the firmware includes the other features about power
> saving, performance, hw behavior, and so on. Thus, I think it  is the extended
> feature. Any suggestion?

RTL_FEATURE_FW_LOADED

[...]
> I don't sure if the firmware code still exists and works after hibernation. I
> clear the flag for safe. It would be set again after loading firmware. It is
> used to make sure to enable ALDPS with firmware.

I don't understand if you want to avoid a coding bug or a hardware problem.

The code only enables ALDPS in the hw_phy_config helpers. Said helpers are
the only places where firmware loading is requested. Loading the firmware
always set RTL_FEATURE_XYZ.

Whatever you are trying to achieve, the change in rtl8169_net_suspend
seem rather useless. Please explain.

(if you want to enforce that ALDPS does nothing when it is not called
right after firmware loading, the ALDPS enable method itself is imho the
natural place to reset the bit).

[...]
> > After this patch the driver would look like:
> > 1. disable ALDPS before setting firmware (unmodified by patch)
> >    RTL_GIGA_MAC_VER_29 "RTL8105e"
> >    RTL_GIGA_MAC_VER_30 "RTL8105e"
> >    RTL_GIGA_MAC_VER_37 "RTL8402"
> >    RTL_GIGA_MAC_VER_39 "RTL8106e"
> > 
> > 2. apply_firmware (unmodified by patch)
> >    RTL_GIGA_MAC_VER_25 "RTL8168d/8111d"
> >    RTL_GIGA_MAC_VER_26 "RTL8168d/8111d"
> >    RTL_GIGA_MAC_VER_29 "RTL8105e"
> >    RTL_GIGA_MAC_VER_30 "RTL8105e"
> >    RTL_GIGA_MAC_VER_32 "RTL8168e/8111e"
> >    RTL_GIGA_MAC_VER_33 "RTL8168e/8111e"
> >    RTL_GIGA_MAC_VER_34 "RTL8168evl/8111evl"
> >    RTL_GIGA_MAC_VER_35 "RTL8168f/8111f"
> >    RTL_GIGA_MAC_VER_36 "RTL8168f/8111f"
> >    RTL_GIGA_MAC_VER_37 "RTL8402"
> >    RTL_GIGA_MAC_VER_38 "RTL8411"
> >    RTL_GIGA_MAC_VER_39 "RTL8106e"
> >    RTL_GIGA_MAC_VER_40 "RTL8168g/8111g"
> > 
> > 3. enable ALDPS after firmware
> >    RTL_GIGA_MAC_VER_34 "RTL8168evl/8111evl"
> >    RTL_GIGA_MAC_VER_35 "RTL8168f/8111f"
> >    RTL_GIGA_MAC_VER_36 "RTL8168f/8111f"
> >    RTL_GIGA_MAC_VER_37 "RTL8402"
> >    RTL_GIGA_MAC_VER_38 "RTL8411"
> >    RTL_GIGA_MAC_VER_39 "RTL8106e"
> >    RTL_GIGA_MAC_VER_40 "RTL8168g/8111g"
> > 
> > The disable/enable ALDPS code is not trivially balanced.
> > 
> > Do we exactly perform the required ALDPS operations ? Nothing more,
> > nothing less ?
> > 
> 
> Because the different design between the giga nic and 10/100M nic, the behavior
> would be different. For example, you couldn't disable the ALDPS of the giga nic
> directly just like the 10/100M (8136 series) one. The giga nic would disable
> ALDPS automatically when loading firmware, but the 8136 series wouldn't.

It would be nice to state these things in the commit message, namely:
- ALDPS should never be enabled for the RTL8105e
- none of the firmware-free chipsets support ALDPS
- neither do the RTL8168d/8111d

-- 
Ueimor
