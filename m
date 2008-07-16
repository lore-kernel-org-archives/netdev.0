From: "J. K. Cliburn" <jcliburn@gmail.com>
Subject: Re: sendfile() broken with 2.6.26 + Apache 2 ?
Date: Wed, 16 Jul 2008 08:38:52 -0500
Message-ID: <487DF9EC.9060202@bellsouth.net>
References: <487CD7A7.2080800@jeffray.co.uk> <487D893A.5080207@cosmosbay.com> <487DA388.3030104@jeffray.co.uk> <487DBA74.3090800@cosmosbay.com>
Reply-To: jacliburn@bellsouth.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ian Jeffray <ian@jeffray.co.uk>, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	csnook@redhat.com, jeff@garzik.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:55619 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756339AbYGPNi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 09:38:59 -0400
Received: by py-out-1112.google.com with SMTP id p76so3351349pyb.10
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2008 06:38:58 -0700 (PDT)
In-Reply-To: <487DBA74.3090800@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Ian Jeffray a =E9crit :
>> Hi Eric,
>>
>> Thanks for directing me to a better list.
>>
>> Further responses below:
>>
>> Eric Dumazet wrote:
>>> CC to netdev where this report might find better answers
>>>
>>> Ian Jeffray a =E9crit :
>>>> All,
>>>>
>>>> I moved from kernel 2.6.25.4 to 2.6.26 yesterday and observed that
>>>> large files sent via Apache2 are partially corrupt.
>>>>
>>>> This appears to be linked to sendfile() -- disabling the use of
>>>> sendfile in the apache config (EnableSendfile Off) allows it to
>>>> function as normal.

>>>
>>>
>>> What kind of network adapter are you using ? (lspci | grep -i ether=
)
>>
>> 02:00.0 Ethernet controller: Attansic Technology Corp. L1 Gigabit=20
>> Ethernet Adapter (rev b0)
>>
>>
>>> If you disable TCP segmentation offload on this NIC (ethtool -K eth=
0=20
>>> tso off) , is this problem still present ?
>>
>> Wow.  That 'solves' the problem!  Great.
>>
>> Does this therefore point to an attansic driver issue?
>>
>=20
>=20
> Yes, maybe related to commit 9d90fb1ac9d97da86e24d9ea947bf2a2f333829a
> In this patch, Jay Cliburn enabled TSO by default for atl1 driver.
>=20
> This might be a driver problem, or a generic sendfile() problem, I do=
nt=20
> know...

I'm currently traveling and unable to delve into this issue and its=20
relation to the atl1 driver.  I should be able to look at it this=20
weekend when I get back home.

Jay
