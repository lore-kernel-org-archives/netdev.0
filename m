From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [TCP] IPV6 : Change a divide into a right shift in tcp_v6_send_ack()
Date: Fri, 21 Dec 2007 06:26:48 -0500
Message-ID: <476BA2F8.1090102@garzik.org>
References: <476B574E.80601@cosmosbay.com> <20071221.155030.131184865.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dada1@cosmosbay.com, davem@davemloft.net, netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56700 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751321AbXLUL06 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2007 06:26:58 -0500
In-Reply-To: <20071221.155030.131184865.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
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

Quite true -- thus it is a matter of taste to the programmer.  Constant=
=20
folding inside the compiler ensures that "foo / 4" asm output is just a=
s=20
optimal as a shift.


> And, IMHO, because shift for signed variable is fragile, so we should
> avoid using it.

I respectfully disagree, but this is an unrelated matter.  As you say,=20
"/4" is fine as-is.

	Jeff


