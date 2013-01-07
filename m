From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH v2] sctp: Change defaults on cookie hmac selection
Date: Mon, 07 Jan 2013 16:15:24 +0100
Message-ID: <50EAE68C.2050300@openwrt.org>
References: <1355511060-27320-1-git-send-email-nhorman@tuxdriver.com> <1355534521-32719-1-git-send-email-nhorman@tuxdriver.com> <50EACCD3.90609@openwrt.org> <20130107144921.GA31577@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:53599 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387Ab3AGPR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 10:17:56 -0500
In-Reply-To: <20130107144921.GA31577@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/07/13 15:49, Neil Horman a =C3=A9crit :
> On Mon, Jan 07, 2013 at 02:25:39PM +0100, Florian Fainelli wrote:
>> Hello Neil,
>>
>> Le 12/15/12 02:22, Neil Horman a =C3=A9crit :
>>> Recently I posted commit 3c68198e75 which made selection of the coo=
kie hmac
>>> algorithm selectable.  This is all well and good, but Linus noted t=
hat it
>>> changes the default config:
>>> http://marc.info/?l=3Dlinux-netdev&m=3D135536629004808&w=3D2
>>>
>>> I've modified the sctp Kconfig file to reflect the recommended way =
of making
>>> this choice, using the thermal driver example specified, and brough=
t the
>>> defaults back into line with the way they were prior to my origiona=
l patch
>>>
>>> Also, on Linus' suggestion, re-adding ability to select default 'no=
ne' hmac
>>> algorithm, so we don't needlessly bloat the kernel by forcing a non=
-none
>>> default.  This also led me to note that we won't honor the default =
none
>>> condition properly because of how sctp_net_init is encoded.  Fix th=
at up as
>>> well.
>>>
>>> Tested by myself (allbeit fairly quickly).  All configuration combi=
nations seems
>>> to work soundly.
>>>
>>> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>>> CC: David Miller <davem@davemloft.net>
>>> CC: Linus Torvalds <torvalds@linux-foundation.org>
>>> CC: Vlad Yasevich <vyasevich@gmail.com>
>>> CC: linux-sctp@vger.kernel.org
>>> ---
>>>   net/sctp/Kconfig    | 27 +++++++++++++++++++++++++--
>>>   net/sctp/protocol.c |  4 ++--
>>>   2 files changed, 27 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/net/sctp/Kconfig b/net/sctp/Kconfig
>>> index a9edd2e..c262106 100644
>>> --- a/net/sctp/Kconfig
>>> +++ b/net/sctp/Kconfig
>>> @@ -66,12 +66,36 @@ config SCTP_DBG_OBJCNT
>>>   	  'cat /proc/net/sctp/sctp_dbg_objcnt'
>>>
>>>   	  If unsure, say N
>>> +choice
>>> +	prompt "Default SCTP cookie HMAC encoding"
>>> +	default SCTP_COOKIE_HMAC_MD5
>> Should not this be SCTP_DEFAULT_COOKIE_HMAC_MD5? I just tried to
>> update to 3.8-rc2, and I usually build my kernel-headers with:
>>
>> yes '' | ARCH=3Dfoo make oldconfig
>>
>> and this just kept asking me for this config symbol because none
>> could be provided.
>> --
>> Florian
>>
> No, the config mechanism is setup to offer the user the ability to ch=
oose a
> default cookie hmac, alg, then optionally select any other hmac algs =
you would
> like to be made available (in the event you want to change the defaul=
t at run
> time).  When you select the default, it eables (via the select direct=
ive), the
> corresponding SCTP_COOKIE_HMAC_* config option, which is used in the =
build, and
> then prompts for the remaining values.

Ok for the explanation, but this still breaks an oldconfig because we d=
o=20
not actually propose the user with a default choice:

     choice[1-3?]:     Default SCTP cookie HMAC encoding
       1. Enable optional MD5 hmac cookie generation=20
(SCTP_DEFAULT_COOKIE_HMAC_MD5) (NEW)
       2. Enable optional SHA1 hmac cookie generation=20
(SCTP_DEFAULT_COOKIE_HMAC_SHA1) (NEW)
       3. Use no hmac alg in SCTP cookie generation=20
(SCTP_DEFAULT_COOKIE_HMAC_NONE) (NEW)

I do not see any difference in what I am proposed if the default config=
=20
symbol is SCTP_DEFAULT_COOKIE_HMAC_MD5, I can still optionally choose=20
SHA1 to be supported, and I do have a valid default config for this=20
choice. While if I keep SCTP_COOKIE_HMAC_MD5 as the default I have to=20
manually enter which option I want.
--
=46lorian
