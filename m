From: Doug Berger <opendmb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 02/12] net: phy: bcm7xxx: add support for 28nm
 EPHY
Date: Tue, 14 Mar 2017 10:23:27 -0700
Message-ID: <1a487139-ffd9-0598-54da-29986f1e795f@gmail.com>
References: <20170314004142.4746-1-opendmb@gmail.com>
 <20170314004142.4746-3-opendmb@gmail.com> <20170314010651.GO15842@lunn.ch>
 <3e5f7ac9-7e97-60f1-3986-4045522a65f5@gmail.com>
 <20170314024320.GQ15842@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, rafal-g1n6cQUeyibVItvQsEIGlw@public.gmane.org, xow-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
        joel-U3u1mxZcP9KHXe+LvDLADg@public.gmane.org, jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        pgynther-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, jaedon.shin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170314024320.GQ15842-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/13/2017 07:43 PM, Andrew Lunn wrote:
> On Mon, Mar 13, 2017 at 07:06:25PM -0700, Doug Berger wrote:
>> On 03/13/2017 06:06 PM, Andrew Lunn wrote:
>>> On Mon, Mar 13, 2017 at 05:41:32PM -0700, Doug Berger wrote:
>>>> +static int bcm7xxx_28nm_ephy_01_afe_config_init(struct phy_device *phydev)
>>>> +{
>>>> +	int ret;
>>>> +
>>>> +	/* set shadow mode 2 */
>>>> +	ret = phy_set_clr_bits(phydev, MII_BCM7XXX_TEST,
>>>> +			       MII_BCM7XXX_SHD_MODE_2, 0);
>>>> +	if (ret < 0)
>>>> +		return ret;
>>>> +
>>>> +	/* Set current trim values INT_trim = -1, Ext_trim =0 */
>>>> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_BIAS_TRIM, 0x3BE0);
>>>> +	if (ret < 0)
>>>> +		goto reset_shadow_mode;
>>>> +
>>>> +	/* Cal reset */
>>>> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_ADDR_CTRL,
>>>> +			MII_BCM7XXX_SHD_3_TL4);
>>>> +	if (ret < 0)
>>>> +		goto reset_shadow_mode;
>>>
>>> Hi Doug
>>>
>>> It would be nice to have a few blank lines here and there...
>>>
>> Thanks for taking the time to review this.
>>
>> In general I try to keep lines of related functionality together and use
>> the blank lines to help identify boundaries.  In this particular case, I
>> believe it is clearer to keep the code that may return an error code
>> together with the code that tests for the error.
> 
> Hi Doug
> 
> I agree with that. Which is why i placed the comment between the goto
> and the next block of code. This is where i think there should be a
> blank line, to separate it from setting the trim values.
> 
OK, I see.  I thought you were referring to the code blocks above the
comment.  In that case, as described earlier, the code below the comment
is tightly coupled with the code above the comment since the pair of
transactions are how we "/* Cal reset */".  The idea of introducing a
subroutine/helper function for these paired (addr/data) transactions
might help readability so I will consider it for a future patch.

Thanks again for the feedback,
    Doug
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
