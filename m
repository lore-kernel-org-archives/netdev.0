From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [TCP] IPV6 : Change a divide into a right shift in tcp_v6_send_ack()
Date: Fri, 21 Dec 2007 08:06:32 +0100
Message-ID: <476B65F8.10201@cosmosbay.com>
References: <476B574E.80601@cosmosbay.com> <20071221.155030.131184865.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:33816 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750776AbXLUHGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 02:06:48 -0500
In-Reply-To: <20071221.155030.131184865.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E a =C3=A9crit :
> In article <476B574E.80601@cosmosbay.com> (at Fri, 21 Dec 2007 07:03:=
58 +0100), Eric Dumazet <dada1@cosmosbay.com> says:
>=20
>> Because tot_len is signed in tcp_v6_send_ack(), tot_len/4 forces com=
piler
>> to emit an integer divide, while we can help it to use a right shift=
,
>> less expensive.
>=20
> Are you really sure?
> At least, gcc-4.1.2-20061115 (debian) does not make any difference.
>=20
> And, IMHO, because shift for signed variable is fragile, so we should
> avoid using it.
>=20

Yes I am sure, but maybe you are on x86_64 ?

gcc-4.2.2 on x86

# objdump --disassemble net/ipv6/tcp_ipv6.o|grep -6 idiv
       b2:       66 8b 42 02             mov    0x2(%edx),%ax
       b6:       ba 04 00 00 00          mov    $0x4,%edx
       bb:       89 d7                   mov    %edx,%edi
       bd:       66 89 45 00             mov    %ax,0x0(%ebp)
       c1:       89 d8                   mov    %ebx,%eax
       c3:       99                      cltd
       c4:       f7 ff                   idiv   %edi
       c6:       88 c2                   mov    %al,%dl
       c8:       8a 45 0c                mov    0xc(%ebp),%al
       cb:       c1 e2 04                shl    $0x4,%edx
       ce:       83 e0 0f                and    $0xf,%eax
       d1:       09 d0                   or     %edx,%eax
       d3:       88 45 0c                mov    %al,0xc(%ebp)


If you think tot_len can be negative, I understand you can be against t=
his=20
patch. But I am sure it's allways > 0, even if I am a total ipv6 newbie=
 :)

Thank you
