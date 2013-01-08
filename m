From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH v2] sctp: Change defaults on cookie hmac selection
Date: Tue, 08 Jan 2013 13:28:26 -0500
Message-ID: <50EC654A.9070506@gmail.com>
References: <1355511060-27320-1-git-send-email-nhorman@tuxdriver.com> <1355534521-32719-1-git-send-email-nhorman@tuxdriver.com> <50EACCD3.90609@openwrt.org> <20130107144921.GA31577@hmsreliant.think-freely.org> <50EAEA71.1060007@gmail.com> <20130107154625.GD31577@hmsreliant.think-freely.org> <50EAFA2A.3000200@gmail.com> <50EC5BE7.3090401@openwrt.org> <50EC60B8.4070205@gmail.com> <50EC6378.7020505@inktank.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Fainelli <florian@openwrt.org>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-sctp@vger.kernel.org
To: Alex Elder <elder@inktank.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f45.google.com ([209.85.212.45]:53523 "EHLO
	mail-vb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757024Ab3AHS2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 13:28:31 -0500
In-Reply-To: <50EC6378.7020505@inktank.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/08/2013 01:20 PM, Alex Elder wrote:
> On 01/08/2013 12:08 PM, Vlad Yasevich wrote:
>> On 01/08/2013 12:48 PM, Florian Fainelli wrote:
>>> Le 01/07/13 17:39, Vlad Yasevich a =C3=A9crit :
>>>>>
>>>>>> Would that save all the config trouble?
>>>>>>
>>>>> Yes, it would fix it as Florian has noted, but at the cost of
>>>>> silently modifying
>>>>> what the default hmac config vaule is.  If you've expressly disab=
led
>>>>> SCTP_COOKIE_HMAC_MD5, and then blindly take the default choice in=
 the
>>>>> SCTP_DEFAULT_COOKIE selection option (the default default as it
>>>>> were), using the
>>>>> approach your suggesting, then that will silently enable
>>>>> SCTP_COOKIE_HMAC_MD5
>>>>> again, which may not be expected by users.  If you expressly have=
 a
>>>>> config
>>>>> option disabled in an old configuration, we should leave it there=
=2E
>>>>
>>>> GACK.  Just reproduced this and I really don't like this infinite =
loop
>>>> of choice prompts.  That's a horrible bug and we need to fix this.
>>>>
>>>> I don't think overriding the value is that big of a deal, especial=
ly
>>>> considering that this is exactly what 'make menuconfig' and other
>>>> graphical configs will do.
>>>> If I start with:
>>>>      CONFIG_IP_SCTP=3Dm
>>>>      CONFIG_NET_SCTPPROBE=3Dm
>>>>      # CONFIG_SCTP_DBG_MSG is not set
>>>>      # CONFIG_SCTP_DBG_OBJCNT is not set
>>>>      # CONFIG_SCTP_HMAC_NONE is not set
>>>>      CONFIG_SCTP_HMAC_SHA1=3Dy
>>>>      # CONFIG_SCTP_HMAC_MD5 is not set
>>>>
>>>> then run:
>>>>      yes "" | make oldconfig
>>>>
>>>> I get an infinite loop.
>>>>
>>>> If I run "make menuconfig", I get:
>>>>      CONFIG_IP_SCTP=3Dm
>>>>      CONFIG_NET_SCTPPROBE=3Dm
>>>>      # CONFIG_SCTP_DBG_MSG is not set
>>>>      # CONFIG_SCTP_DBG_OBJCNT is not set
>>>>      CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5=3Dy
>>>>      # CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1 is not set
>>>>      # CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE is not set
>>>>      CONFIG_SCTP_COOKIE_HMAC_MD5=3Dy
>>>>      # CONFIG_SCTP_COOKIE_HMAC_SHA1 is not set
>>>>
>>>> Note, that SHA1 is now overridden with MD5.
>>>>
>>>> If I change the value of the default choice in Kconfig, the behavi=
or
>>>> between oldconfig and menuconfig is the same.
>>>
>>> Right, the issue is as simple as there is no default *valid* config
>>> symbol being proposed. In any case Neil's patch changes both config
>>> symbol names such that they are non-existent when transitionning fr=
om a
>>> pre-3.8-rc config and a 3.8-rc config. The following patch fixes th=
is
>>> for me:
>>>
>>>   From c8e277512bafafc009a3fbf889c78d6b6a06d5fa Mon Sep 17 00:00:00=
 2001
>>> From: Florian Fainelli <florian@openwrt.org>
>>> Date: Mon, 7 Jan 2013 14:26:15 +0100
>>> Subject: [PATCH] sctp: fix typo in default SCTP cookie choice
>>>
>>> Commit 0d0863b0 (sctp: Change defaults on cookie hmac selection)
>>> introduced a choice configuration option to select the default SCTP
>>> cookie hashing algorithm, a typo was introduced for the default cho=
ice.
>>> This is an issue when running make oldconfig because an explicit ch=
oice
>>> number must be entered since no default is available. This patch fi=
xes
>>> the typo, thus providing a valid default choice.
>>>
>>> Signed-off-by: Florian Fainelli <florian@openwrt.org>
>>
>> Hi Florian
>>
>> Alex Alder already sent the patch that Neil and I both acked, but I =
see
>> that Alex never sent it to netdev (just checked the headers).
>>
>> Oh well...  this is the same change that Alex sent, so ACK, and now =
it
>> can get into the tree.
>>
>> Acked-by: Vlad Yasevich <vyasevich@gmail.com>
>>
>> Alex, please be sure to CC your patches to netdev as well.
>
> Sorry, I just sent my messages to the addresses listed
> on the commit that introduced the problem this fixed.
>
> Linus already pulled in the patch.
>

I see.. Then this is a noop ;)

-vlad

> 					-Alex
>
>> Thanks
>> -vlad
>>
>>> ---
>>>    net/sctp/Kconfig |    2 +-
>>>    1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/net/sctp/Kconfig b/net/sctp/Kconfig
>>> index c262106..7521d94 100644
>>> --- a/net/sctp/Kconfig
>>> +++ b/net/sctp/Kconfig
>>> @@ -68,7 +68,7 @@ config SCTP_DBG_OBJCNT
>>>          If unsure, say N
>>>    choice
>>>        prompt "Default SCTP cookie HMAC encoding"
>>> -    default SCTP_COOKIE_HMAC_MD5
>>> +    default SCTP_DEFAULT_COOKIE_HMAC_MD5
>>>        help
>>>          This option sets the default sctp cookie hmac algorithm
>>>          when in doubt select 'md5'
>>
>
