From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] net: change capability used by socket options
 IP{,V6}_TRANSPARENT
Date: Tue, 20 Sep 2011 15:42:13 -0400 (EDT)
Message-ID: <20110920.154213.888729603269720228.davem@redhat.com>
References: <1314953022.26692.182.camel@bzorp>
	<1314990654-32252-1-git-send-email-zenczykowski@gmail.com>
	<1315927629.5851.4.camel@bzorp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zenczykowski@gmail.com, maze@google.com, netdev@vger.kernel.org
To: bazsi@balabit.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43631 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750832Ab1ITTmV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2011 15:42:21 -0400
In-Reply-To: <1315927629.5851.4.camel@bzorp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Balazs Scheidler <bazsi@balabit.hu>
Date: Tue, 13 Sep 2011 17:27:09 +0200

> On Fri, 2011-09-02 at 12:10 -0700, Maciej =AFenczykowski wrote:
>> From: Maciej =AFenczykowski <maze@google.com>
>>=20
>> Up till now the IP{,V6}_TRANSPARENT socket options (which actually s=
et
>> the same bit in the socket struct) have required CAP_NET_ADMIN
>> privileges to set or clear the option.
>>=20
>> - we make clearing the bit not require any privileges.
>> - we deprecate using CAP_NET_ADMIN for this purpose.
>> - we introduce a new capability CAP_NET_TRANSPARENT,
>>   which is tailored to allow setting just this bit.
>> - we allow either one of CAP_NET_TRANSPARENT or CAP_NET_RAW
>>   to set this bit, because raw sockets already effectively
>>   allow you to emulate socket transparency, and make the
>>   transition easier for apps not desiring to use a brand
>>   new capability (because of header file or glibc support)
>> - we print a warning (but allow it) if you try to set
>>   the socket option with CAP_NET_ADMIN privs, but without
>>   either one of CAP_NET_TRANSPARENT or CAP_NET_RAW.
>>=20
>> The reason for introducing a new capability is that while
>> transparent sockets are potentially dangerous (and can let you
>> spoof your source IP on traffic), they don't normally give you
>> the full 'freedom' of eavesdropping and/or spoofing that raw sockets
>> give you.
>>=20
>> Signed-off-by: Maciej =AFenczykowski <maze@google.com>
>> CC: Balazs Scheidler <bazsi@balabit.hu>
>=20
> This is ok for me, as long as the security maintainers allow the
> introduction of this new cap.
>=20
> Thanks for doing this and sorry for the late reply.
>=20
> Acked-by: Balazs Scheidler <bazsi@balabit.hu>

I'm fine with this change too and I'll apply it as soon as at least
one security person ACK's the addition of the new capability bit.
