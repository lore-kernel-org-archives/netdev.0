From: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH 1/3] driver: net: ethernet: cpsw: implement ethtool get/set
 phy setting
Date: Fri, 8 Mar 2013 20:37:00 +0530
Message-ID: <5139FE94.6090004@ti.com>
References: <1362659421-11884-1-git-send-email-mugunthanvnm@ti.com>
 <1362659421-11884-2-git-send-email-mugunthanvnm@ti.com>
 <8762135on4.fsf@dell.be.48ers.dk>
 <1362686350.2936.43.camel@bwh-desktop.uk.solarflarecom.com>
 <513991E6.5080400@ti.com>
 <1362754401.3248.8.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1362754401.3248.8.camel-/LGg1Z1CJKReKY3V0RtoKmatzQS1i7+A3tAM5lWOD0I@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 3/8/2013 8:23 PM, Ben Hutchings wrote:
> On Fri, 2013-03-08 at 12:53 +0530, Mugunthan V N wrote:
>> On 3/8/2013 1:29 AM, Ben Hutchings wrote:
>>> On Thu, 2013-03-07 at 14:24 +0100, Peter Korsgaard wrote:
>>>>>>>>> "M" == Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org> writes:
>>>>    M> This patch implements get/set of the phy settings via ethtool apis
>>>>    M> Signed-off-by: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
>>>>    M> ---
>>>>    M>  Documentation/devicetree/bindings/net/cpsw.txt |    3 +++
>>>>    M>  drivers/net/ethernet/ti/cpsw.c                 |   32 ++++++++++++++++++++++++
>>>>    M>  include/linux/platform_data/cpsw.h             |    1 +
>>>>    M>  3 files changed, 36 insertions(+)
>>>>
>>>>    M> diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
>>>>    M> index ecfdf75..8d61300 100644
>>>>    M> --- a/Documentation/devicetree/bindings/net/cpsw.txt
>>>>    M> +++ b/Documentation/devicetree/bindings/net/cpsw.txt
>>>>    M> @@ -20,6 +20,7 @@ Required properties:
>>>>    M>  - cpts_clock_shift	: Denominator to convert input clock ticks into nanoseconds
>>>>    M>  - phy_id		: Specifies slave phy id
>>>>    M>  - mac-address		: Specifies slave MAC address
>>>>    M> +- ethtool-active-slave	: Specifies the slave to use for ethtool command
>>>>
>>>> That again sounds like something Linux specific rather than a hardware
>>>> property.
>>> Yes, indeed.  Isn't it redundant with the phy_id?
>>>
>>> Ben.
>> phy_id is part of slave data and will be present for both the slaves.
>> so phy_id cannot be used for get/set phy setting until phy framework
>> allows to change settings without going through eth interface.
> Now I've looked at the examples in this file, I think I see what you're
> getting at.  What confused me is that you're adding to a single list of
> properties without a proper distinction of which devices they are
> applied to.  It really ought to be properly divided between switch and
> 'slave' properties.
Will fix this in next patch series.
> The 'active slave' property would also be needed for the SIOCGMIIPHY
> ioctl and not just ethtool.  But it's really quite arbitrary.  Perhaps
> each of them should have their own net device (as with DSA).
But if we have net device for each of the slaves then it is dual EMAC 
which will kill
hardware switching functionality. To achieve switching bridge has to be 
done and
there will be a performance drop as well.

As Peter Korsgaard mentioned we need to have infrastructure to handle CPSW
kind of hardware.

Regards
Mugunthan V N
