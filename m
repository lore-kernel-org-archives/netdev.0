From: "Arend van Spriel" <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: calling request_firmware() from module init will not work
 with recent/future udev versions
Date: Sat, 14 Jan 2012 20:59:52 +0100
Message-ID: <4F11DEB8.7010708@broadcom.com>
References: <CAPXgP11iT9K2KcDCJvw_druf5qdNjs0jLfrbpS7CcYh5vXrz_w@mail.gmail.com>
 <20120114175837.GA8504@tuxdriver.com> <4F11C75F.9030105@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"Kay Sievers" <kay.sievers-tD+1rO4QERM@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Tom Gundersen" <teg-B22kvLQNl6c@public.gmane.org>,
	"Andy Whitcroft" <apw-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	"Johannes Berg" <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
To: "Larry Finger" <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F11C75F.9030105-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/14/2012 07:20 PM, Larry Finger wrote:
> On 01/14/2012 11:58 AM, John W. Linville wrote:
>> Kay, thanks for the reports.  Drivers should definitely be loading
>> firmware at IFF_UP time.
> 
> As the maintainer for several drivers with this problem, I need to make some 
> changes. What call from mac80211 corresponds to IFF_UP?

Hi, Larry

The mac80211 start callback describes following:

 * @start: Called before the first netdevice attached to the hardware
 *	is enabled. This should turn on the hardware and must turn on
 *	frame reception (for possibly enabled monitor interfaces.)
 *	Returns negative error codes, these may be seen in userspace,
 *	or zero.
 *	When the device is started it should not have a MAC address
 *	to avoid acknowledging frames before a non-monitor device
 *	is added.
 *	Must be implemented and can sleep.

Seems to me a good place to do the firmware loading although it is not
really IFF_UP.

> I have looked into using asynchronous firmware loading, but I have not yet found 
> a good implementation.
> 
> Larry

In brcmsmac we request the firmware in the probe function so not in
module_init, but I guess upon driver registration in the module_init the
probe is called.

Gr. AvS

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
