From: Thomas Backlund <tmb-4qZELD6Fgxhg9hUCZPvPmw@public.gmane.org>
Subject: Re: linux-2..6.33-rc7 and b43
Date: Sun, 14 Feb 2010 20:44:40 +0200
Message-ID: <4B784498.8030509@mandriva.org>
References: <4B77C819.9050602@mandriva.org> <4B782670.9080001@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4B782670.9080001-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Larry Finger skrev 14.2.2010 18:36:
> On 02/14/2010 03:53 AM, Thomas Backlund wrote:
>> Hi,
>> (please cc me on replies)
>>
>> We have a user that tried out b43, but got this in the logs:
>>
>> --- cut ---
>> 65858:Feb  9 22:05:16 elmo kernel: b43-phy2 ERROR: This device does not
>> support DMA on your system. Please use PIO instead. 65859:Feb  9
>> 22:05:16 elmo kernel: b43-phy2 ERROR: CONFIG_B43_FORCE_PIO must
>> be set in your kernel configuration.
>> 65860:Feb  9 22:05:16 elmo kernel: b43-phy2 debug: Adding Interface type 2
>> 65861:Feb  9 22:05:16 elmo kernel: b43-phy2 ERROR: Fatal DMA error:
>> 0x00000400, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000
>>
>> 65862:Feb  9 22:05:16 elmo kernel: b43-phy2 ERROR: This device does not
>> support DMA on your system. Please use PIO instead.
>> 65863:Feb  9 22:05:16 elmo kernel: b43-phy2 ERROR: CONFIG_B43_FORCE_PIO
>> must be set in your kernel configuration.
>> --- cut ---
>>
>>
>>
>> But reading the Kconfig help, it states:
>> --- cut ---
>> config B43_FORCE_PIO
>>          bool "Force usage of PIO instead of DMA"
>>          depends on B43&&  B43_DEBUG
>>          ---help---
>>            This will disable DMA and always enable PIO instead.
>>
>>            Say N!
>>            This is only for debugging the PIO engine code. You do
>>            _NOT_ want to enable this.
>> --- cut ---
>>
>>
>> So,
>> wich one is it ?
>>
>> Do I belive the dmesg output, or the Kconfig ?
>>
>> Note,
>> the b43 works for the user if he enable the CONFIG_B43_FORCE_PIO.
>>
>> But I'm thinking of this problem from a distro point of view.
>> Will it break for others if I enable it ?
>
>> From a distro point of view, you would not want to set FORCE_PIO as the
> performance penalty would be very large.
>

As I suspected.
Thanks for confirming it.

> You do not give the specific details on the problem system; however, it is
> probably a BCM4312 802.11 b/g device with PCI ID 14e4:4315 being used with an
> Atom processor in a netbook. We have no fix.
>

Sorry about the missing info...
I asked a few times from the user, and got no reponse until today a few 
hours after your response...

It is indeed a BCM4312 802.11 b/g device with PCI ID 14e4:4315 on a Dell 
laptop with a Intel ICH9M series chipset and a Intel Core(TM)2 Duo CPU 
T7250 @ 2.00GHz.

> In the 2.6.34 code, b43 will be changed to allow the selection of PIO mode at
> run time rather than compile time. For a distro, this method is clearly
> superior. Those users that need PIO can select it without forcing the
> performance penalty on everyone. The patch was too late for the 2.6.33 merge,
> and too intrusive to be applied to 2.6.33-rcX. It has been present in the
> wireless-testing code base for 2 months with no trouble reported, thus it should
> be safe for inclusion in your kernels. The relevant patch is attached.
>

Nice solution.

What about making it autodetected ?
Or is it only a "last resort" with the hopes of getting the issue fixed?

Anyway, thanks for the patch.

--
Thomas
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
