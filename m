From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 2/4] net: systemport: use the new fixed PHY helpers
Date: Mon, 19 May 2014 14:52:57 -0700
Message-ID: <CAGVrzcYwp6W7YgDmAbe3d+LEX105d+s1j2jV4zvAm52rWTt5rg@mail.gmail.com>
References: <1400528625-32744-1-git-send-email-f.fainelli@gmail.com>
 <1400528625-32744-3-git-send-email-f.fainelli@gmail.com> <20140519221946.27dbad55@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140519221946.27dbad55-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2014-05-19 13:19 GMT-07:00 Thomas Petazzoni
<thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>:
> Dear Florian Fainelli,
>
> On Mon, 19 May 2014 12:43:43 -0700, Florian Fainelli wrote:
>> +     priv->phydev = of_phy_connect(dev, priv->phy_dn, bcm_sysport_adj_link,
>> +                                     0, priv->phy_interface);
>>       if (!priv->phydev) {
>>               netdev_err(dev, "could not attach to PHY\n");
>>               return -ENODEV;
>> @@ -1551,6 +1551,20 @@ static int bcm_sysport_probe(struct platform_device *pdev)
>>       if (priv->phy_interface < 0)
>>               priv->phy_interface = PHY_INTERFACE_MODE_GMII;
>>
>> +     /* SYSTEMPORT uses the old 'fixed-link' 5-digit property which is
>> +      * deprecated, we need to register the fixed PHY using the Ethernet
>> +      * MAC node since we do not have a 'fixed-link' subnode.
>> +      */
>
> Actually even if you use the new fixed PHY DT binding, the DT node
> linked to the PHY is the Ethernet MAC node. This is because I didn't
> want to have a difference between how things are handled between the
> old and the new binding.

Sure, I agree, and the comment still stands, I am just expressing it
that we are not looking for the 'fixed-link' subnode, but the
'fixed-link' 5-digit property here. Would you want me to rephrase
that?
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
