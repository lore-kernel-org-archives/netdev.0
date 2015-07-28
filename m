From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCHv2] net/ipv6: add sysctl option accept_ra_hop_limit
Date: Tue, 28 Jul 2015 11:05:36 +0800
Message-ID: <CAPwn2JSk0P8n+aSxTGiU0Q2RSSbZ52NVZxOS+yURpor2YQVySQ@mail.gmail.com>
References: <1437978942-7047-1-git-send-email-liuhangbin@gmail.com>
	<55B6C3AF.1050504@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: network dev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kv5ZCJ6Jek6Iux5piO?=
	<hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:33186 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754333AbbG1DFh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 23:05:37 -0400
Received: by obdeg2 with SMTP id eg2so74628440obd.0
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 20:05:37 -0700 (PDT)
In-Reply-To: <55B6C3AF.1050504@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-07-28 7:50 GMT+08:00 YOSHIFUJI Hideaki/=E5=90=89=E8=97=A4=E8=8B=B1=
=E6=98=8E
<hideaki.yoshifuji@miraclelinux.com>:
> Hi,
>
> Hangbin Liu wrote:
>> Commit 6fd99094de2b ("ipv6: Don't reduce hop limit for an interface"=
)
>> disabled accept hop limit from RA if it is higher than the current h=
op
>> limit for security stuff. But this behavior kind of break the RFC de=
finition.
>>
>> RFC 4861, 6.3.4.  Processing Received Router Advertisements
>>    If the received Cur Hop Limit value is non-zero, the host SHOULD =
set
>>    its CurHopLimit variable to the received value.
>>
>> So add sysctl option accept_ra_hop_limit to let user choose whether =
accept
>> hop limit info in RA.
>>
>
> How about introducing "minimum hop limit", instead?

Hi Yoshifuji,

This is a good idea. Maybe this can be another sysctl option?

The minimum hop limit can be an enhancement of the security issue, then=
 we will
not only increase the hop limit, but also could decrease it in the
range of values we
accept.

On the other hand, with this patch, we can enable, disable or partly
enable accept
hop limit. If we only use "minimum hop limit", people could not use a s=
tatic hop
limit value.

May be we use a =E2=80=9Chop limit range" instead? How do you think?

Thanks
Hangbin

>
> |commit 6fd99094de2b83d1d4c8457f2c83483b2828e75a
> |Author: D.S. Ljungmark <ljungmark@modio.se>
> |Date:   Wed Mar 25 09:28:15 2015 +0100
> |
> |    ipv6: Don't reduce hop limit for an interface
> :
> |    RFC 3756, Section 4.2.7, "Parameter Spoofing"
> |
> :
> |   >   As an example, one possible approach to mitigate this threat =
is to
> |    >   ignore very small hop limits.  The nodes could implement a
> |    >   configurable minimum hop limit, and ignore attempts to set i=
t below
> |    >   said limit.
