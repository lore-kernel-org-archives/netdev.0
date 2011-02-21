From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH v2 2/2] r8169: Support RTL8105E
Date: Mon, 21 Feb 2011 17:17:20 +0800
Message-ID: <417606D3EB3A4B72AA3BEDC38D45C2B6@realtek.com.tw>
References: <1298018085-1370-1-git-send-email-hayeswang@realtek.com> <1298018085-1370-2-git-send-email-hayeswang@realtek.com> <20110221073328.GA12326@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110221073328.GA12326@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Monday, February 21, 2011 3:33 PM
> To: Hayeswang
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH v2 2/2] r8169: Support RTL8105E
> 
> > @@ -267,6 +272,12 @@ enum rtl8168_8101_registers {
> >  #define	EPHYAR_REG_MASK			0x1f
> >  #define	EPHYAR_REG_SHIFT		16
> >  #define	EPHYAR_DATA_MASK		0xffff
> > +	DLLPR			= 0xd0,
> > +#define	PM_SWITCH			(1 << 6)
> > +	TWSI			= 0xd2,
> > +	MCU			= 0xd3,
> > +#define	EN_NDP				(1 << 3)
> > +#define	EN_OOB_RESET			(1 << 2)
> >  	DBG_REG			= 0xd1,
> >  #define	FIX_NAK_1			(1 << 4)
> >  #define	FIX_NAK_2			(1 << 3)
> 
> Please pack them in increasing order and it will be perfect 
> (i.e. 0xd0, 0xd1, 0xd2, 0xd3 instead of current 0xd0, 0xd2 
> (?), 0xd3, 0xd1).

It's my mistake. I would fix that.

> 
> > +	rtl_writephy(tp, 0x1f, 0x0000);
> > +	rtl_writephy(tp, 0x18, 0x0310);
> > +	msleep(100);
> > +
> > +	if (rtl_apply_firmware(tp, FIRMWARE_8105E_1) < 0)
> > +		netif_warn(tp, probe, tp->dev, "unable to apply 
> firmware patch\n");
> > +
> > +	rtl_writephy_batch(tp, phy_reg_init, 
> ARRAY_SIZE(phy_reg_init)); }
> 
> The "if (RTL_R8(0xef) & 0x08)" and "if (RTL_R8(0xef) & 
> 0x010)" conditionals from the previous iteration have been 
> removed. If it is done on purpose, a short explanation or 
> notification in the description of the patch is always welcome.
> 

These two conditions are using for customization. I remove them and use the
default settings.
 
Best Regards,
Hayes
