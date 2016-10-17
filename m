From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 2/2] net: phy: Add Fast Link Failure - 2 set driver for Microsemi PHYs.
Date: Mon, 17 Oct 2016 05:51:11 -0700
Message-ID: <838C6202-9B7D-4AFA-B163-55515044FA4F@gmail.com>
References: <1476445233-26524-1-git-send-email-Raju.Lakkaraju@microsemi.com> <1476445233-26524-3-git-send-email-Raju.Lakkaraju@microsemi.com> <20161014120228.GF5822@lunn.ch> <20161017081312.GB2365@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Allan.Nielsen-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org
To: Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161017081312.GB2365-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On October 17, 2016 1:13:14 AM PDT, Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org> wrote:
>Hi Andrew,
>
>Thank you for code review and comments.
>
>On Fri, Oct 14, 2016 at 02:02:28PM +0200, Andrew Lunn wrote:
>> EXTERNAL EMAIL
>> 
>> 
>> > On Fri, Oct 14, 2016 at 05:10:33PM +0530, Raju Lakkaraju wrote:
>> > From: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
>> >
>> > VSC8531 Fast Link Failure 2 feature enables the PHY to indicate the
>> > onset of a potential link failure in < 100 usec for 100BASE-TX
>> > operation. FLF2 is supported through the MDINT (active low) pin.
>> 
>> Is the MDINT pin specific to this feature, or a general interrupt
>pin?
>> 
>
>MDINT pin is general interrupt. MDINT pin share the interrupt with
>FLF2 along with another 13 interrupts.
>
>> Device tree is used to describe the hardware. It should not really
>> describe software or configuration. But the borders are a bit
>> fluffly. Signal edge rates is near to hardware. This is a lot more
>> towards configuration. So i'm not sure a device tree property is the
>> correct way to describe this.
>> 
>> This is also a feature i know other PHYs support. The Marvell PHY has
>> a "Metro Ethernet" extension which allows it to report link failures
>> for 1000BASE-T in 10, 20 or 40ms, instead of the usual 750ms. So we
>> need a generic solution other PHYs can implement.
>> 
>> As with cable testing, i think it should be an ethtool option.
>
>I agree with you.
>I thought this is one time initialization either enable or disable.
>if customer need this feature, they can enable in DT.
>Do you want me to implement through IOCTL instead of Device tree?
>Do you have any other suggestions?

As indicated in the other email about speed downshift, we may want to utilize ethtool's ability to modify tunable parameters (small integer, boolean, values) and extend it to cover features offered by PHYs in a way that an user can dynamically turn these features on or off.

In fact, this looks a lot like netdev features (e.g: checksum offload), and there seems to be some commonality here between at least Marvell and Microsemi (for the faster link down reporting), so maybe we should start adding PHY features similar to netdev features?

-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
