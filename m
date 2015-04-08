From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH] iputils ping: add (non-raw) ICMP socket support
Date: Wed, 08 Apr 2015 21:05:34 +0900
Message-ID: <5525198E.7030509@miraclelinux.com>
References: <2142872.6QHf5ZAfZz@msg-id> <1749676.NUxJ1eyH1x@msg-id> <5524F2EB.4000908@miraclelinux.com> <5093199.DdecKAOFEl@msg-id>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hideaki.yoshifuji@miraclelinux.com,
	Vasiliy Kulikov <segooon@gmail.com>,
	Tyler Hicks <tyhicks@canonical.com>
To: Salvatore Mesoraca <s.mesoraca16@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og115.obsmtp.com ([64.18.2.217]:35041 "HELO
	exprod7og115.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751344AbbDHMFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 08:05:40 -0400
Received: by paboj16 with SMTP id oj16so112972202pab.0
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 05:05:38 -0700 (PDT)
In-Reply-To: <5093199.DdecKAOFEl@msg-id>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Salvatore Mesoraca wrote:
> In data mercoled=EC 8 aprile 2015 18:20:43, YOSHIFUJI Hideaki ha scri=
tto:
>> Salvatore Mesoraca wrote:
>>> YOSHIFUJI Hideaki wrote:
>>>> Hi,
>>>
>>> Hi,
>>> thank you for thaking to the time to answer
>>>
>>>> Salvatore Mesoraca wrote:
>>>>> From: Vasiliy Kulikov <segooon@gmail.com>
>>>>>
>>>>> This patch adds non-raw IPPROTO_ICMP socket kind support that was=
 added
>>>>> to the Linux 3.0.  The patch is backward-compatible: if ICMP sock=
et kind
>>>>> is not enabled in the kernel (either in case of an old kernel or
>>>>> explicitly disabled via /proc/sys/net/ipv4/ping_group_range), pin=
g uses
>>>>> old privileged raw sockets as a fallback.
>>>>>
>>>>> This patch is going to be included in Ubuntu 15.10 and it is alre=
ady
>>>>> included in Gentoo stable tree (at the moment of the writing ping=
 has
>>>>> CAP_NET_RAW still enabled by default) it is also included in Open=
Wall
>>>>> since 2011.
>>>>> This patch also tries to sneak in a fix for a missing colon in a =
printf.
>>>>> I've tested it on Linux 3.17.7 and it worked without issues.
>>>>
>>>> Please do not mix changes in a single commit.
>>>> Thanks.
>>>
>>> I had some doubt about that additional change (it is so small that =
I don't
>>> think that anyone will ever make a separate patch for it), but it w=
as
>>> present in the original patch and I decided to add it anyway and wa=
it for
>>> feedback. I'll delete it.
>>> Thank you again for you comment.
>>
>> What I meant was changes not for supporting non-raw icmp socket
>> should be formed separately.  It seems that the patch try to
>> change other things as well, in receive_error_msg() for example.
>>
>> --yoshfuji
>=20
> Thank you for the clarification.
> If I understood correctly you were referring to these lines:
>> @@ -652,9 +687,18 @@ int receive_error_msg()
>>             goto out;
>>         }
>>
>> -       acknowledge(ntohs(icmph.un.echo.sequence));
>> +       error_pkt =3D (e->ee_type !=3D ICMP_REDIRECT &&
>> +                e->ee_type !=3D ICMP_SOURCE_QUENCH);
>> +       if (error_pkt) {
>> +           acknowledge(ntohs(icmph.un.echo.sequence));
>> +           net_errors++;
>> +           nerrors++;
>> +       }
>> +       else {
>> +           saved_errno =3D 0;
>> +       }
>=20
>=20
> In my understanding these changes are required to support non-raw ICM=
P sockets=20
> because they cannot use setsockopt(icmp_sock, SOL_RAW, ICMP_FILTER...=
) and=20
> they need to get rid of ICMP_REDIRECT and ICMP_SOURCE_QUENCH in a dif=
ferent=20
> way. IMHO this change alone does not make much sense.

OK, I understand.


> Anyway if you think that this and other changes should be in differen=
t commits=20
> I'll post a split PATCHv2.

No, please just exclude this from first patch:
-			printf("From %s icmp_seq=3D%u ", pr_addr(sin->sin_addr.s_addr), nto=
hs(icmph.un.echo.sequence));
+			printf("From %s: icmp_seq=3D%u ", pr_addr(sin->sin_addr.s_addr), nt=
ohs(icmph.un.echo.sequence));


And, would you provide patch for ping6 as well?

Thank you.

--=20
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
