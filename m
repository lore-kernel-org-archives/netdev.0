From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] net: change capability used by socket options IP{,V6}_TRANSPARENT
Date: Tue, 13 Sep 2011 23:45:26 -0700
Message-ID: <CAHo-OoyGVzG-UDr=BMoLXVUdn2xBfFWtcp-jb9qKMyxvzJeniA@mail.gmail.com>
References: <1314953022.26692.182.camel@bzorp>
	<1314990654-32252-1-git-send-email-zenczykowski@gmail.com>
	<1315927629.5851.4.camel@bzorp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Balazs Scheidler <bazsi@balabit.hu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:42084 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991Ab1INGp1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2011 02:45:27 -0400
Received: by gyg10 with SMTP id 10so1161263gyg.19
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2011 23:45:27 -0700 (PDT)
In-Reply-To: <1315927629.5851.4.camel@bzorp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> From: Maciej =C5=BBenczykowski <maze@google.com>
>>
>> Up till now the IP{,V6}_TRANSPARENT socket options (which actually s=
et
>> the same bit in the socket struct) have required CAP_NET_ADMIN
>> privileges to set or clear the option.
>>
>> - we make clearing the bit not require any privileges.
>> - we deprecate using CAP_NET_ADMIN for this purpose.
>> - we introduce a new capability CAP_NET_TRANSPARENT,
>> =C2=A0 which is tailored to allow setting just this bit.
>> - we allow either one of CAP_NET_TRANSPARENT or CAP_NET_RAW
>> =C2=A0 to set this bit, because raw sockets already effectively
>> =C2=A0 allow you to emulate socket transparency, and make the
>> =C2=A0 transition easier for apps not desiring to use a brand
>> =C2=A0 new capability (because of header file or glibc support)
>> - we print a warning (but allow it) if you try to set
>> =C2=A0 the socket option with CAP_NET_ADMIN privs, but without
>> =C2=A0 either one of CAP_NET_TRANSPARENT or CAP_NET_RAW.
>>
>> The reason for introducing a new capability is that while
>> transparent sockets are potentially dangerous (and can let you
>> spoof your source IP on traffic), they don't normally give you
>> the full 'freedom' of eavesdropping and/or spoofing that raw sockets
>> give you.
>>
>> Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
>> CC: Balazs Scheidler <bazsi@balabit.hu>
>
> This is ok for me, as long as the security maintainers allow the
> introduction of this new cap.
>
> Thanks for doing this and sorry for the late reply.
>
> Acked-by: Balazs Scheidler <bazsi@balabit.hu>
>
> --
> Bazsi

I'm not really sure who else to CC on this...
