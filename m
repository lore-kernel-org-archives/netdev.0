From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH v2] sctp: Change defaults on cookie hmac selection
Date: Tue, 08 Jan 2013 18:36:50 +0100
Message-ID: <50EC5932.4040407@openwrt.org>
References: <1355511060-27320-1-git-send-email-nhorman@tuxdriver.com> <1355534521-32719-1-git-send-email-nhorman@tuxdriver.com> <50EACCD3.90609@openwrt.org> <20130107144921.GA31577@hmsreliant.think-freely.org> <50EAE68C.2050300@openwrt.org> <20130107153812.GC31577@hmsreliant.think-freely.org> <50EAEE64.5010300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-sctp@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:50927 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756777Ab3AHRjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 12:39:22 -0500
In-Reply-To: <50EAEE64.5010300@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/07/13 16:48, Vlad Yasevich a =C3=A9crit :
> No, thats the problem, your old config is no longer valid with this=20
> new Kconfig
>> file.  Your config is telling the config utility that you want your=20
>> default
>> Cookie hmac to be MD5, but you've explicitly told it (via your yes "=
"=20
>> | make
>> oldconfig command), that you want SCTP_COOKIE_HMAC_MD5 to be=20
>> disabled, so the
>> config utility is left with no choice to prompt you again for a=20
>> default hmac,
>> which your command answers again by saying=20
>> SCTP_DEFAULT_COOKIE_HMAC_MD5 (the
>> default choice of 1).  Thats your loop, you keep telling the config=20
>> utility that
>> you both want the default hmac to be md5, and that you don't want to=
=20
>> allow md5
>> to be an available hmac alg.
>>
>> Thats not a bug.  I'm sorry if your old configuration needs manual=20
>> updating, but
>> there are no guarantees that old configurations will 'just work' in=20
>> perpituity.
>>
>
> Neil
>
> Actually, I think we have a bug in the config.  Look at the thermal=20
> driver config again.  It has:
>
> choice
>         prompt "Default Thermal governor"
>         default THERMAL_DEFAULT_GOV_STEP_WISE
>
> config THERMAL_DEFAULT_GOV_STEP_WISE
>     ...
> config THERMAL_DEFAULT_GOV_FAIR_SHARE
>     ...
> config THERMAL_DEFAULT_GOV_USER_SPACE
>     ...
> endchoice
>
>
> SCTP has:
>
> choice
>         prompt "Default SCTP cookie HMAC encoding"
>         default SCTP_COOKIE_HMAC_MD5
>
> config SCTP_DEFAULT_COOKIE_HMAC_MD5
>     ...
> config SCTP_DEFAULT_COOKIE_HMAC_SHA1
>     ...
> config SCTP_DEFAULT_COOKIE_HMAC_NONE
>     ...
> endchoice
>
> See the difference?  The default value of the choice statement needs =
to
> be one of the available choices.

Right, since none of the config symbols actually exist when migrating=20
from and oldconfig we are still being prompted, which is just fine=20
actually. Having the config symbol being the default a member of the=20
choice/endchoice section is what should be expected.
--
=46lorian
