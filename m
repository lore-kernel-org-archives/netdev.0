From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: getsockopt(TCP_DEFER_ACCEPT) value change
Date: Tue, 05 Jan 2010 16:45:57 +0100
Message-ID: <4B435EB5.1010902@free.fr>
References: <4B4317AD.1040302@free.fr> <alpine.DEB.2.00.1001051526520.7024@wel-95.cs.helsinki.fi> <4B4348A7.4090509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Julian Anastasov <ja@ssi.bg>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.17.165]:45376 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754658Ab0AEPqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 10:46:00 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.1/8.13.1) with ESMTP id o05FjxLM015597
	for <netdev@vger.kernel.org>; Tue, 5 Jan 2010 15:45:59 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o05FjxEh1433774
	for <netdev@vger.kernel.org>; Tue, 5 Jan 2010 16:45:59 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o05Fjwdv013793
	for <netdev@vger.kernel.org>; Tue, 5 Jan 2010 16:45:59 +0100
In-Reply-To: <4B4348A7.4090509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le 05/01/2010 14:40, Ilpo J=E4rvinen a =E9crit :
>  =20
>> On Tue, 5 Jan 2010, Daniel Lezcano wrote:
>>
>>    =20
>>> I noticed a change in the value returned by the getsockopt for the
>>> TCP_DEFER_ACCEPT option with a 2.6.32 kernel. The value retrieved w=
ith the
>>> getsockopt is different from the one specified with the setsockopt.=
 Is it an
>>> expected behaviour ?
>>>
>>> I saw there were  changes around the TCP_DEFER_ACCEPT option with t=
he number
>>> of attempts converted to a number of seconds.
>>>
>>> The following program is working fine with a 2.6.31 but fails with =
a 2.6.32
>>> kernel.
>>>
>>> Thanks
>>>  -- Daniel
>>>
>>> #include <stdio.h>
>>> #include <sys/socket.h>
>>> #include <netinet/in.h>
>>> #include <netinet/tcp.h>
>>>
>>> int main(int argc, char *argv[])
>>> {
>>>    int val1 =3D 12, val2;
>>>    socklen_t len =3D sizeof(val2);
>>>    int fd;
>>>      fd =3D socket(PF_INET, SOCK_STREAM, 0);
>>>    if (fd < 0) {
>>>        perror("socket");
>>>        return -1;
>>>    }
>>>      if (setsockopt(fd, SOL_TCP, TCP_DEFER_ACCEPT, &val1, sizeof(va=
l1))) {
>>>        perror("setsockopt");
>>>        return -1;
>>>    }
>>>      if (getsockopt(fd, SOL_TCP, TCP_DEFER_ACCEPT, &val2, &len)) {
>>>        perror("getsockopt");
>>>        return -1;
>>>    }
>>>
>>>    if (val1 !=3D val2) {
>>>        fprintf(stderr, "error %d !=3D %d\n", val1, val2);
>>>        return -1;
>>>    }
>>>
>>>    return 0;
>>> }
>>>      =20
>> Added Cc.
>>
>> I don't think this change was intentional. ...However, is this diffe=
rence=20
>> particularly significant besides failing such a test program? The ac=
tual=20
>> value now returned by the getsockopt is more accurate than what the
>> userspace initially provided.
>>
>> In general, I wonder if there's something that mandates that a set/g=
et=20
>> pair of value should be equal?
>>
>>    =20
>
> Nothing... really... we can round the value, and we indeed round it i=
n 2.6.32
>
> defer value is given in second by user, and converted to number of re=
transmits by kernel.
>
> Program assumption is wrong.
>  =20
It's not problem if the set / get values are not same, but I was asking=
=20
because I am working with a test suite checking if a checkpoint /=20
restart solution is correct.  One of these tests, sets the=20
TCP_DEFER_ACCEPT value to 12, checkpoints / restarts, and reads the=20
value in order to check if it was correctly restored. The value 12 was=20
chosen because it is not rounded, so we were able to safely do the test=
=2E=20
But with the 2.6.32, the behaviour changed, so I preferred to report it=
=20
in case that is something not expected.


