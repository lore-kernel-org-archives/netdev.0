From: Hau <hau@realtek.com>
Subject: RE: [PATCH net 1/3] r8169:fix kernel log spam when set or get hardware wol setting.
Date: Thu, 28 Jul 2016 12:58:44 +0000
Message-ID: <80377ECBC5453840BA8C7155328B53770143B749@RTITMBSV03.realtek.com.tw>
References: <1469637668-8751-1-git-send-email-hau@realtek.com>
 <1469637668-8751-2-git-send-email-hau@realtek.com>
 <20160727221001.GA3338@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160727221001.GA3338@electric-eye.fr.zoreil.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[...]
> > @@ -1852,12 +1863,17 @@ static int rtl8169_set_wol(struct net_device
> *dev, struct ethtool_wolinfo *wol)
> >  		tp->features |= RTL_FEATURE_WOL;
> >  	else
> >  		tp->features &= ~RTL_FEATURE_WOL;
> > -	__rtl8169_set_wol(tp, wol->wolopts);
> > +	if (pm_runtime_active(&pdev->dev))
> > +		__rtl8169_set_wol(tp, wol->wolopts);
> > +	else
> > +		tp->saved_wolopts = wol->wolopts;
> >
> >  	rtl_unlock_work(tp);
> >
> >  	device_set_wakeup_enable(&tp->pci_dev->dev, wol->wolopts);
> >
> > +	pm_runtime_put_noidle(&pdev->dev);
> > +
> >  	return 0;
> 
> Either the driver resumes the device so that it can perform requested
> operation or it signals .set_wol failure when the device is suspended.
> 
> If the driver does something else, "spam removal" translates to "silent
> failure".

Because "tp->saved_wolopts" will be used to set hardware wol capability in rtl8169_runtime_resume().  So I prefer to keep "wol->wolopts" to " tp->saved_wolopts " in runtime suspend state and set this to this "wol->wolopts" to hardware in in rtl8169_runtime_resume(). 

Thanks.

------Please consider the environment before printing this e-mail.
