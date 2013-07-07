From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] rtlwifi: Fix Kconfig for some corner cases
Date: Sun, 07 Jul 2013 13:13:06 -0500
Message-ID: <51D9AFB2.2030707@lwfinger.net>
References: <1373165244-9536-1-git-send-email-Larry.Finger@lwfinger.net> <1373190151.3428.13.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1373190151.3428.13.camel-nDn/Rdv9kqW9Jme8/bJn5UCKIB8iOfG2tUK59QYPAWc@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 07/07/2013 04:42 AM, Ben Hutchings wrote:
> On Sat, 2013-07-06 at 21:47 -0500, Larry Finger wrote:
>>
>> Although I could not duplicate this result on my machine, it seemed likely
>> that it was due to the unusual configuration where rtlwifi was being built,
>> but none of its dependent drivers were selected.
>
> I think it just requires:
>
> CONFIG_USB=m
> CONFIG_RTLWIFI=y
>
>> The fix is to select rtlwifi only when it is needed.
>
> I don't think so.  Consider this configuration:
>
> CONFIG_PCI=y
> CONFIG_USB=m
> CONFIG_RTL_CARDS=y
> CONFIG_RTL8192CE=y
> CONFIG_RTL8192CU=m
> CONFIG_RTLWIFI=y     # maximum of RTL8192CE=y and RTL8192CU=m
>
> The same breakage occurs.

Ben,

Thanks for your comments. I certainly do not claim to understand very much about 
the whole Kbuild process.

After setting up the above configuration manually, I ran 'make oldconfig' and 
got back

CONFIG_RTL_CARDS=m
CONFIG_RTL8192CE=m
CONFIG_RTL8192SE=m
CONFIG_RTL8192DE=m
CONFIG_RTL8723AE=m
CONFIG_RTL8188EE=m
CONFIG_RTL8192CU=m
CONFIG_RTLWIFI=m
CONFIG_RTLWIFI_DEBUG=y
CONFIG_RTL8192C_COMMON=m

That set of configuration parameters built normally.

>> While making this
>> change, I simplified the configuration so that variable RTLWIFI is never seen
>> by the user.
> [...]
>
> This will break existing configurations as RTL_CARDS defaults to n.

I added a 'default y' to the RTL_CARDS stanza. I now get the following:

finger@larrylap:~/staging> make
scripts/kconfig/conf --silentoldconfig Kconfig
*
* Restart config...
*
*
* Realtek rtlwifi family of devices
*
Realtek rtlwifi family of devices (RTL_CARDS) [M/n/?] (NEW)

That should prevent breakage of existing configurations. It defaults to "m" 
because mac80211 is built as a module in my configuration.

> Perhaps you should introduce separate modules for the common PCI and USB
> support code, similarly to how the rt2x00 modules are organised.

That would not be very difficult, but it would involve converting the single 
module rtlwifi into 3 separate entities. Does that make sense to you? I'm not sure.

Thanks again for your comments.

Larry



--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
