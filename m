From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH RFC] iwlwifi: add basic runtime PM support
Date: Fri, 06 Jan 2012 10:47:49 +0100
Message-ID: <1325843269.3330.4.camel@jlt3.sipsolutions.net>
References: <4F065F59.2070107@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Yan, Zheng" <zheng.z.yan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F065F59.2070107-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

[add linux-wireless]

On Fri, 2012-01-06 at 10:41 +0800, Yan, Zheng wrote:
> This simple patch adds open/close based runtime PM support to the iwlwifi driver.
> Namely, make the driver suspend the device after shutting down the interface and
> resume the device when activating the interface. In my test, suspending the device
> can save about 0.4 watt power. The shortcoming is that the device no longer generate
> rfkill changes interrupt.

NACK due to that last sentence. There's no way we can live with that in
the general case -- and your patch isn't even configurable afaict. And
I'm sure polling the rfkill flag would use just as much energy.

There might be some value in this in a system that doesn't have a hard
rfkill line, but that means this needs to be configurable since the
device can't know whether there's a button or not [1].

johannes

[1] actually in theory it might be possible to determine whether or not
the pin is floating or not? I doubt even that is possible with the HW we
have though

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
