From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v3 0/9] Phy, mdiobus, and netdev struct device fixes
Date: Thu, 24 Sep 2015 15:51:37 -0700 (PDT)
Message-ID: <20150924.155137.1429397912516096627.davem@davemloft.net>
References: <20150924215731.GE20825@lunn.ch>
	<20150924.151554.619662567057050978.davem@davemloft.net>
	<20150924222654.GG20825@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	sgoutham-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, rric-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, michal.simek-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, soren.brinkmann-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org,
	isubramanian-qTEPVZfXA3Y@public.gmane.org, grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, leoli-KZfg59tc24xl57MIdRCFDg@public.gmane.org,
	kchudgar-qTEPVZfXA3Y@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: andrew-g2DYL2Zd6BY@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150924222654.GG20825-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Date: Fri, 25 Sep 2015 00:26:54 +0200

> On Thu, Sep 24, 2015 at 03:15:54PM -0700, David Miller wrote:
>> From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
>> Date: Thu, 24 Sep 2015 23:57:31 +0200
>> 
>> > I built the FEC driver as a module, and it won't unload:
>> > 
>> >  kernel:unregister_netdevice: waiting for eth1 to become free. Usage count = 1
>> > unregister_netdevice: waiting for eth1 to become free. Usage count = 1
>> > 
>> > i assume because DSA holds a reference. I've not tried a fully module
>> > build, DSA has issues with that.
>> > 
>> > Tested-by: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
>> 
>> So, is this a regression?
> 
> Sorry, worded that badly. Since DSA is still active, it should not be
> possible to unload the FEC driver. DSA should have a reference to it,
> and mdio-mux also should have a reference to the mdio bus of the FEC
> driver.
> 
> As Russell requested, i will re-test without his patches, just to make
> sure.

Something needs to hold into the underlying device refcount of a DSA
blob so that an unload can't even be attempted in that state.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
