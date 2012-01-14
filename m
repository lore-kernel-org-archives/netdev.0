From: Emmanuel Grumbach <egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: calling request_firmware() from module init will not work with
 recent/future udev versions
Date: Sat, 14 Jan 2012 22:15:19 +0200
Message-ID: <CANUX_P2OGvazES0pGA+RnfWnHNJ6+0Rre9j0SOav_7idHNM-2A@mail.gmail.com>
References: <CAPXgP11iT9K2KcDCJvw_druf5qdNjs0jLfrbpS7CcYh5vXrz_w@mail.gmail.com>
	<20120114175837.GA8504@tuxdriver.com>
	<4F11C75F.9030105@lwfinger.net>
	<4F11DEB8.7010708@broadcom.com>
	<4F11E1CE.2050008@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Tom Gundersen <teg-B22kvLQNl6c@public.gmane.org>,
	Andy Whitcroft <apw-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F11E1CE.2050008-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 14, 2012 at 22:13, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>=
 wrote:
> On 01/14/2012 01:59 PM, Arend van Spriel wrote:
>>
>> On 01/14/2012 07:20 PM, Larry Finger wrote:
>>>
>>> On 01/14/2012 11:58 AM, John W. Linville wrote:
>>>>
>>>> Kay, thanks for the reports. =A0Drivers should definitely be loadi=
ng
>>>> firmware at IFF_UP time.
>>>
>>>
>>> As the maintainer for several drivers with this problem, I need to =
make
>>> some
>>> changes. What call from mac80211 corresponds to IFF_UP?
>>
>>
>> Hi, Larry
>>
>> The mac80211 start callback describes following:
>>
>> =A0* @start: Called before the first netdevice attached to the hardw=
are
>> =A0* =A0 =A0 is enabled. This should turn on the hardware and must t=
urn on
>> =A0* =A0 =A0 frame reception (for possibly enabled monitor interface=
s.)
>> =A0* =A0 =A0 Returns negative error codes, these may be seen in user=
space,
>> =A0* =A0 =A0 or zero.
>> =A0* =A0 =A0 When the device is started it should not have a MAC add=
ress
>> =A0* =A0 =A0 to avoid acknowledging frames before a non-monitor devi=
ce
>> =A0* =A0 =A0 is added.
>> =A0* =A0 =A0 Must be implemented and can sleep.
>>
>> Seems to me a good place to do the firmware loading although it is n=
ot
>> really IFF_UP.
>>
>>> I have looked into using asynchronous firmware loading, but I have =
not
>>> yet found
>>> a good implementation.
>>>
>>> Larry
>>
>>
>> In brcmsmac we request the firmware in the probe function so not in
>> module_init, but I guess upon driver registration in the module_init=
 the
>> probe is called.
>
>

I looked once at the pci_register_driver, and if I remember well, the
probe in called in the same context of pci_register_driver. The driver
registration fires a bus enumeration.
=46WIW, drivers might need to fetch their fw before registering
mac80211. This can happen if they need their fw to know their
capabilities...

>
> The rtlwifi drivers also load the firmware in the probe function, but=
 do so
> synchronously, which is where they get in trouble with the new udev.
>
> I'm planning on converting to asynchronous firmware loading with a ch=
eck in
> the start routine.
>

so does iwlwifi
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
