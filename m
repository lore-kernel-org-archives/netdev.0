From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Tue, 25 Aug 2009 08:46:12 +0200
Message-ID: <4A9388B4.8030401@gmail.com>
References: <alpine.DEB.1.10.0908171548040.20399@gentwo.org>  <4A89C026.4030402@us.ibm.com>  <alpine.DEB.1.10.0908171642500.20399@gentwo.org>  <1250545839.25939.21.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171813070.15956@gentwo.org> <1250549034.25939.30.camel@w-sridhar.beaverton.ibm.com> <alpine.DEB.1.10.0908171848370.15956@gentwo.org> <4A931ED3.1090206@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux-foundation.org>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Nivedita Singhvi <niv@us.ibm.com>, netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50503 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754356AbZHYGqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 02:46:17 -0400
In-Reply-To: <4A931ED3.1090206@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Christoph Lameter a =E9crit :
>> On Mon, 17 Aug 2009, Sridhar Samudrala wrote:
>>
>>> On Mon, 2009-08-17 at 18:13 -0400, Christoph Lameter wrote:
>>>> On Mon, 17 Aug 2009, Sridhar Samudrala wrote:
>>>>
>>>>> What about ethtool -S ? Does it report any errors?
>>>> Neither. This is is a broadcom bnx2 NIC.
>>> Are you sure the packets are dropped at the sender?
>> Yes I am sending 400k messages from the app and the receiver only ge=
ts
>> 341k @300 byte (which is the line rate). There is no way that the 40=
0k get
>> over the line. Also if I reduce SO_SNDBUF then both receiver and
>> sender get down to 341k.
>>
>> I added the output of ethtool -S at the end.
>>
>> The mcast tool can be had from http://gentwo.org/ll or from my direc=
tory
>> on www.kernel.org.
>>
>=20
> # gcc -v
> Using built-in specs.
> Target: i686-pc-linux-gnu
> Configured with: ../gcc-4.4.1/configure --enable-languages=3Dc,c++ --=
prefix=3D/usr
> Thread model: posix
> gcc version 4.4.1 (GCC)
> # pwd
> /opt/src/lldiag-0.14
> # make
> gcc -Wall -omcast mcast.c -lrt -lm
> mcast.c: In function =91set_ip=92:
> mcast.c:121: warning: implicit declaration of function =91htons=92
> mcast.c: In function =91build_pattern_array=92:
> mcast.c:168: warning: implicit declaration of function =91htonl=92
> /tmp/cc4sYCDr.o: In function `lock':
> mcast.c:(.text+0xcad): undefined reference to `__sync_fetch_and_add_4=
'
> collect2: ld returned 1 exit status
> make: *** [mcast] Error 1
>=20
>=20
> I have no idea where is defined sync_fetch_and_add
>=20

Doh...

Dont bother, I had to add "-march=3Di686" to CFLAGS to get "xadd" suppo=
rt

