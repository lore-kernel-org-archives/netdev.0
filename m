From: =?KOI8-R?B?5M3J1NLJyiDiwczBy8nO?= <dmitriy.balakin@nicneiron.ru>
Subject: Re: Fw: [Bug 24842] New: Compatibility issue with uggly Windows
 RFC1323 implementation.
Date: Mon, 13 Dec 2010 23:44:00 +0300
Message-ID: <AANLkTikTgbKSNYHthic8P3bi9+ewN8fEBknnSK=tdTgU@mail.gmail.com>
References: <20101213085913.374c1072@nehalam> <1292260479.2759.69.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:45589 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753899Ab0LMUoV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 15:44:21 -0500
Received: by gyb11 with SMTP id 11so3232675gyb.19
        for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 12:44:20 -0800 (PST)
In-Reply-To: <1292260479.2759.69.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/12/13 Eric Dumazet <eric.dumazet@gmail.com>:
> Le lundi 13 d=E9cembre 2010 =E0 08:59 -0800, Stephen Hemminger a =E9c=
rit :
>>
>> Begin forwarded message:
>>
>> Date: Mon, 13 Dec 2010 14:29:58 GMT
>> From: bugzilla-daemon@bugzilla.kernel.org
>> To: shemminger@linux-foundation.org
>> Subject: [Bug 24842] New: Compatibility issue with uggly Windows RFC=
1323 implementation.
>>
>>
>> https://bugzilla.kernel.org/show_bug.cgi?id=3D24842
>>
>> =A0 =A0 =A0 =A0 =A0 =A0Summary: Compatibility issue with uggly Windo=
ws RFC1323
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 implementation.
>> =A0 =A0 =A0 =A0 =A0 =A0Product: Networking
>> =A0 =A0 =A0 =A0 =A0 =A0Version: 2.5
>> =A0 =A0 Kernel Version: All
>> =A0 =A0 =A0 =A0 =A0 Platform: All
>> =A0 =A0 =A0 =A0 OS/Version: Linux
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 Tree: Mainline
>> =A0 =A0 =A0 =A0 =A0 =A0 Status: NEW
>> =A0 =A0 =A0 =A0 =A0 Severity: normal
>> =A0 =A0 =A0 =A0 =A0 Priority: P1
>> =A0 =A0 =A0 =A0 =A0Component: IPV4
>> =A0 =A0 =A0 =A0 AssignedTo: shemminger@linux-foundation.org
>> =A0 =A0 =A0 =A0 ReportedBy: dmitriy.balakin@nicneiron.ru
>> =A0 =A0 =A0 =A0 Regression: No
>>
>>
>> Created an attachment (id=3D40012)
>> =A0--> (https://bugzilla.kernel.org/attachment.cgi?id=3D40012)
>> Patch
>>
>> First, sorry for my bad english.
>>
>> The issue is that Linux-based OS sometimes can't make an tcp connect=
ion to some
>> Windows servers with switched on buggy implementation of rfc1323, th=
at
>> described on this forum:
>> http://www.network-builders.com/windows-tcp-timestamp-not-compliant-=
rfc-1323-a-t80898.html.
>>
>> Because some Windows hosts implementation of rfc1323 bases on random=
ly
>> generated TSval and sent first value of TSval as 0, the difference o=
f recent
>> and new TSval sometimes has been affected by a sign magic issue and =
the PAWS
>> mechanism has been triggered. Anyway, the rfc1323 has discribes the =
condition
>> of PAWS as "0 < (t - s) < 2**31", that has been right implementation=
 in current
>> linux kernel, but incompatible with Windows bug.
>>
>> For example, the one of affected to this issue Windows host is behin=
d
>> relay.n-l-e.ru:80
>>
>> I think that my small patch makes the kernel more compatible with th=
is windows
>> bug.
>>
>> -
>
> I have no problem connecting my linux client to relay.n-l-e.ru:80
>
> Could you elaborate please ?
>
> 18:13:12.444250 IP 10.150.51.215.51781 > 212.176.201.162.80: Flags [S=
],
> seq 665972386, win 5840, options [mss 1460,sackOK,TS val 1746885 ecr
> 0,nop,wscale 7], length 0
> 18:13:12.473912 IP 212.176.201.162.80 > 10.150.51.215.51781: Flags [S=
=2E],
> seq 190215045, ack 665972387, win 5792, options [mss 1460,sackOK,TS v=
al
> 730697107 ecr 1746885,nop,wscale 0], length 0
> 18:13:12.473976 IP 10.150.51.215.51781 > 212.176.201.162.80: Flags [.=
],
> ack 1, win 46, options [nop,nop,TS val 1746888 ecr 730697107], length=
 0
> 18:13:14.984153 IP 10.150.51.215.51781 > 212.176.201.162.80: Flags [P=
=2E],
> seq 1:8, ack 1, win 46, options [nop,nop,TS val 1747139 ecr 730697107=
],
> length 7
> 18:13:15.013901 IP 212.176.201.162.80 > 10.150.51.215.51781: Flags [.=
],
> ack 8, win 5792, options [nop,nop,TS val 730697360 ecr 1747139], leng=
th
> 0
> 18:13:15.377879 IP 10.150.51.215.51781 > 212.176.201.162.80: Flags [P=
=2E],
> seq 8:10, ack 1, win 46, options [nop,nop,TS val 1747178 ecr 73069736=
0],
> length 2
> 18:13:15.403900 IP 212.176.201.162.80 > 10.150.51.215.51781: Flags [.=
],
> ack 10, win 5792, options [nop,nop,TS val 730697399 ecr 1747178], len=
gth
> 0
> 18:13:15.461384 IP 212.176.201.162.80 > 10.150.51.215.51781: Flags [P=
=2E],
> seq 1:159, ack 10, win 5792, options [nop,nop,TS val 730697405 ecr
> 1747178], length 158
> 18:13:15.461429 IP 10.150.51.215.51781 > 212.176.201.162.80: Flags [.=
],
> ack 159, win 54, options [nop,nop,TS val 1747186 ecr 730697405], leng=
th
> 0
> 18:13:15.461448 IP 212.176.201.162.80 > 10.150.51.215.51781: Flags [F=
=2E],
> seq 159, ack 10, win 5792, options [nop,nop,TS val 730697405 ecr
> 1747178], length 0
> 18:13:15.461607 IP 10.150.51.215.51781 > 212.176.201.162.80: Flags [F=
=2E],
> seq 10, ack 160, win 54, options [nop,nop,TS val 1747186 ecr 73069740=
5],
> length 0
> 18:13:15.533846 IP 212.176.201.162.80 > 10.150.51.215.51781: Flags [.=
],
> ack 11, win 5792, options [nop,nop,TS val 730697412 ecr 1747186], len=
gth
> 0
>
>
>

Problems occur only when the remote side sets the TC val > 2147483647,
ie when there is a sign:

23:40:52.726909 IP 213.141.147.8.33778 > 212.176.201.162.80: Flags
[S], seq 1116163452, win 5840, options [mss 1460,sackOK,TS val 141403
ecr 0,nop,wscale 6], length 0
23:40:52.737227 IP 212.176.201.162.80 > 213.141.147.8.33778: Flags
[S.], seq 4019723831, ack 1116163453, win 16384, options [mss
1360,nop,wscale 0,nop,nop,TS val 0 ecr 0,nop,nop,sackOK], length 0
23:40:52.737392 IP 213.141.147.8.33778 > 212.176.201.162.80: Flags
[.], ack 1, win 92, options [nop,nop,TS val 141405 ecr 0], length 0
23:40:52.737926 IP 213.141.147.8.33778 > 212.176.201.162.80: Flags
[P.], seq 1:113, ack 1, win 92, options [nop,nop,TS val 141405 ecr 0],
length 112
23:40:52.749101 IP 212.176.201.162.80 > 213.141.147.8.33778: Flags
[P.], seq 1:415, ack 113, win 65423, options [nop,nop,TS val
3503477357 ecr 141403], length 414
23:40:52.749219 IP 213.141.147.8.33778 > 212.176.201.162.80: Flags
[.], ack 1, win 92, options [nop,nop,TS val 141408 ecr 0], length 0
23:40:53.002253 IP 213.141.147.8.33778 > 212.176.201.162.80: Flags
[P.], seq 1:113, ack 1, win 92, options [nop,nop,TS val 141472 ecr 0],
length 112
23:40:53.012252 IP 212.176.201.162.80 > 213.141.147.8.33778: Flags
[P.], ack 113, win 65423, options [nop,nop,TS val 0 ecr 141408],
length 0
23:40:55.665916 IP 212.176.201.162.80 > 213.141.147.8.33778: Flags
[P.], seq 1:415, ack 113, win 65423, options [nop,nop,TS val
3503477387 ecr 141408], length 414
23:40:55.666023 IP 213.141.147.8.33778 > 212.176.201.162.80: Flags
[.], ack 1, win 92, options [nop,nop,TS val 142137 ecr 0], length 0
23:40:55.676963 IP 212.176.201.162.80 > 213.141.147.8.33778: Flags
[P.], seq 1:415, ack 113, win 65423, options [nop,nop,TS val
3503477387 ecr 142137], length 414
23:40:55.677007 IP 213.141.147.8.33778 > 212.176.201.162.80: Flags
[.], ack 1, win 92, options [nop,nop,TS val 142140 ecr 0], length 0
23:41:01.683646 IP 212.176.201.162.80 > 213.141.147.8.33778: Flags
[P.], seq 1:415, ack 113, win 65423, options [nop,nop,TS val
3503477447 ecr 142140], length 414
23:41:01.683752 IP 213.141.147.8.33778 > 212.176.201.162.80: Flags
[.], ack 1, win 92, options [nop,nop,TS val 143642 ecr 0], length 0
