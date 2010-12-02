From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: bridge netpoll support: mismatch between net core and bridge headers
Date: Thu, 2 Dec 2010 16:57:14 -0500
Message-ID: <AANLkTik93t_JwosCH_SrmeyoRYiXaTxC_6spkL2teZfH@mail.gmail.com>
References: <AANLkTi=hq6S_NvPEkTovkceUe9Orcitj_oHN1mVUW7+A@mail.gmail.com>
 <20101201.163319.193705748.davem@davemloft.net> <AANLkTimO79DLyCb5vXQ04keX6Mjwv32wNQLRZcfyPNF2@mail.gmail.com>
 <20101202.095135.226774598.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:38027 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752892Ab0LBV5g convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 16:57:36 -0500
Received: by ewy5 with SMTP id 5so4697051ewy.19
        for <netdev@vger.kernel.org>; Thu, 02 Dec 2010 13:57:35 -0800 (PST)
In-Reply-To: <20101202.095135.226774598.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 2, 2010 at 12:51, David Miller wrote:
> From: Mike Frysinger <vapier.adi@gmail.com>
>> On Wed, Dec 1, 2010 at 19:33, David Miller wrote:
>>> Attached. =C2=A0Also please provide one of the failing ".config" fi=
les,
>>> and please test if simply going "make oldconfig" unbreaks things.
>>> It may be that randconfig allows configurations that the config
>>> system normally does not allow.
>>
>> hrm, so your patch does fix things. =C2=A0the downside is that it mi=
ght be
>> caused by kgdboe (which isnt in mainline yet). =C2=A0that's the only
>> randconfig i can find so far to cause the issue.
>
> If that's the case you just need to check and make sure that kgdboe
> handles dependencies properly in it's Kconfig changes.
>
> I suspect that simply adding kgdboe as a new "or" case to the
> "def_bool" statement of NETPOLL in driver/net/Kconfig will fix the
> problem.
>
> If kgdboe is using "select" to handle these dependencies, that's the
> bug.

it is using select to enable reverse depends.  i'll look at sending a
fix as you suggest to the kgdb devs.  thanks !
-mike
