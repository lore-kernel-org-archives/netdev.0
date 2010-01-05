From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: getsockopt(TCP_DEFER_ACCEPT) value change
Date: Tue, 05 Jan 2010 15:11:51 +0100
Message-ID: <4B4348A7.4090509@gmail.com>
References: <4B4317AD.1040302@free.fr> <alpine.DEB.2.00.1001051526520.7024@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Lezcano <daniel.lezcano@free.fr>,
	Julian Anastasov <ja@ssi.bg>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:41134 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754179Ab0AEOMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 09:12:09 -0500
In-Reply-To: <alpine.DEB.2.00.1001051526520.7024@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/01/2010 14:40, Ilpo J=E4rvinen a =E9crit :
> On Tue, 5 Jan 2010, Daniel Lezcano wrote:
>=20
>> I noticed a change in the value returned by the getsockopt for the
>> TCP_DEFER_ACCEPT option with a 2.6.32 kernel. The value retrieved wi=
th the
>> getsockopt is different from the one specified with the setsockopt. =
Is it an
>> expected behaviour ?
>>
>> I saw there were  changes around the TCP_DEFER_ACCEPT option with th=
e number
>> of attempts converted to a number of seconds.
>>
>> The following program is working fine with a 2.6.31 but fails with a=
 2.6.32
>> kernel.
>>
>> Thanks
>>  -- Daniel
>>
>> #include <stdio.h>
>> #include <sys/socket.h>
>> #include <netinet/in.h>
>> #include <netinet/tcp.h>
>>
>> int main(int argc, char *argv[])
>> {
>>    int val1 =3D 12, val2;
>>    socklen_t len =3D sizeof(val2);
>>    int fd;
>>      fd =3D socket(PF_INET, SOCK_STREAM, 0);
>>    if (fd < 0) {
>>        perror("socket");
>>        return -1;
>>    }
>>      if (setsockopt(fd, SOL_TCP, TCP_DEFER_ACCEPT, &val1, sizeof(val=
1))) {
>>        perror("setsockopt");
>>        return -1;
>>    }
>>      if (getsockopt(fd, SOL_TCP, TCP_DEFER_ACCEPT, &val2, &len)) {
>>        perror("getsockopt");
>>        return -1;
>>    }
>>
>>    if (val1 !=3D val2) {
>>        fprintf(stderr, "error %d !=3D %d\n", val1, val2);
>>        return -1;
>>    }
>>
>>    return 0;
>> }
>=20
> Added Cc.
>=20
> I don't think this change was intentional. ...However, is this differ=
ence=20
> particularly significant besides failing such a test program? The act=
ual=20
> value now returned by the getsockopt is more accurate than what the
> userspace initially provided.
>=20
> In general, I wonder if there's something that mandates that a set/ge=
t=20
> pair of value should be equal?
>=20

Nothing... really... we can round the value, and we indeed round it in =
2.6.32

defer value is given in second by user, and converted to number of retr=
ansmits by kernel.

Program assumption is wrong.

