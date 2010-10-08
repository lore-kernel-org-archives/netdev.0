From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: [RFC] net: allow FEC driver to not have attached PHY
Date: Fri, 8 Oct 2010 15:58:52 +1000
Message-ID: <4CAEB31C.2030609@snapgear.com>
References: <201010070350.o973oGFE026910@goober.internal.moreton.com.au> <1286457071.2271.4.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dalsmrelay2.nai.com ([205.227.136.216]:59668 "HELO
	dalsmrelay2.nai.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752865Ab0JHGAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 02:00:20 -0400
In-Reply-To: <1286457071.2271.4.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

On 07/10/10 23:11, Ben Hutchings wrote:
> On Thu, 2010-10-07 at 13:50 +1000, Greg Ungerer wrote:
>> Hi All,
>>
>> I have a board with a ColdFire SoC on it with the built-in FEC
>> ethernet module. On this hardware the FEC eth output is directly
>> attached to a RTL8305 4-port 10/100 switch. There is no conventional
>> PHY, the FEC output is direct into the uplink port of the switch
>> chip.
>>
>> This setup doesn't work after the FEC code was switch to using
>> phylib. The driver used to have code to bypass phy detection/setup
>> for this particular board. The phylib probe finds nothing, and of
>> course sets a no-link condition.
>>
>> So, what is the cleanest way to support this?
>>
>> The attached patch adds a config option to do this sort of generically
>> for the FEC driver. But I am wondering if there isn't a better way?
> [...]
>
> Perhaps there could be a null PHY driver which does no MDIO and always
> reports link-up at the expected speed and duplex.  We used something
> like that in the sfc driver for some PHY-less boards (though we use our
> own PHY abstraction, not phylib).

Looks like that is what the FIXED_PHY does.,

Thanks
Greg


------------------------------------------------------------------------
Greg Ungerer  --  Principal Engineer        EMAIL:     gerg@snapgear.com
SnapGear Group, McAfee                      PHONE:       +61 7 3435 2888
8 Gardner Close                             FAX:         +61 7 3217 5323
Milton, QLD, 4064, Australia                WEB: http://www.SnapGear.com
