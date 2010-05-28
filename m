From: Ivan Novick <novickivan@gmail.com>
Subject: Re: Choppy TCP send performance
Date: Fri, 28 May 2010 15:28:22 -0700
Message-ID: <AANLkTilBPOQIb7ua7hl89_EqH9nZdL0XA9Y9bN7fjEfh@mail.gmail.com>
References: <AANLkTilSrX5PifVHlxMjTK-wo_viD8IS_1m1k-vPOlE3@mail.gmail.com>
	<1275081377.2472.13.camel@edumazet-laptop>
	<AANLkTilZxoSEGOhmWdk2RbIGMmCMi2yNJm9rUwIzDIoL@mail.gmail.com>
	<4C003EE5.6070602@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Tim Heath <theath@greenplum.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:40648 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753207Ab0E1W2Y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 May 2010 18:28:24 -0400
Received: by vws9 with SMTP id 9so1585094vws.19
        for <netdev@vger.kernel.org>; Fri, 28 May 2010 15:28:23 -0700 (PDT)
In-Reply-To: <4C003EE5.6070602@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 28, 2010 at 3:08 PM, Rick Jones <rick.jones2@hp.com> wrote:
>
> Unless you think your application will run over 10G, or over a WAN, y=
ou
> shouldn't need anywhere near the size of socket buffer you are gettin=
g via
> autotuning to be able to achieve "link-rate" - link rate with a 1GbE =
LAN
> connection can be achieved quite easily with a 256KB socket buffer.
>
> The first test here is with autotuning going - disregard what netperf
> reports for the socket buffer sizes here - it is calling getsockopt()=
 before
> connect() and before the end of the connection():
>
> raj@spec-ptd2:~/netperf2_trunk$ src/netperf -H s9 -v 2 -l 30 -- -m 12=
8K
> TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to s9.cup.hp.co=
m
> (16.89.132.29) port 0 AF_INET : histogram
> Recv =A0 Send =A0 =A0Send
> Socket Socket =A0Message =A0Elapsed
> Size =A0 Size =A0 =A0Size =A0 =A0 Time =A0 =A0 Throughput
> bytes =A0bytes =A0 bytes =A0 =A0secs. =A0 =A010^6bits/sec
>
> =A087380 =A016384 131072 =A0 =A030.01 =A0 =A0 911.50
>
> Alignment =A0 =A0 =A0Offset =A0 =A0 =A0 =A0 Bytes =A0 =A0Bytes =A0 =A0=
 =A0 Sends =A0 Bytes =A0 =A0Recvs
> Local =A0Remote =A0Local =A0Remote =A0Xfered =A0 Per =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 Per
> Send =A0 Recv =A0 =A0Send =A0 Recv =A0 =A0 =A0 =A0 =A0 =A0 Send (avg)=
 =A0 =A0 =A0 =A0 =A0Recv (avg)
> =A0 =A08 =A0 =A0 =A0 8 =A0 =A0 =A00 =A0 =A0 =A0 0 3.42e+09 =A0131074.=
49 =A0 =A0 26090 =A0 11624.79 294176
>
> Maximum
> Segment
> Size (bytes)
> =A01448
>
>
> Histogram of time spent in send() call.
> UNIT_USEC =A0 =A0 : =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00:=
 =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00
> TEN_USEC =A0 =A0 =A0: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A0=
0: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00
> HUNDRED_USEC =A0: =A0 =A00: =A0 =A03: 21578: =A0378: =A0 94: =A0 20: =
=A0 =A03: =A0 =A02: =A0 =A00: =A0 =A04
> UNIT_MSEC =A0 =A0 : =A0 =A00: =A0 =A04: =A0 =A02: =A0 =A00: =A0 =A00:=
 =A0780: 3215: =A0 =A06: =A0 =A00: =A0 =A01
> TEN_MSEC =A0 =A0 =A0: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A0=
0: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00
> HUNDRED_MSEC =A0: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0=
 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00
> UNIT_SEC =A0 =A0 =A0: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A0=
0: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00
> TEN_SEC =A0 =A0 =A0 : =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A0=
0: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00
>>100_SECS: 0
> HIST_TOTAL: =A0 =A0 =A026090
>
>
> Next, we have netperf make an explicit setsockopt() call for 128KB so=
cket
> buffers, which will get us 256K. =A0Notice that the bandwidth remains=
 the
> same, but the distribution of the time spent in send() changes. =A0It=
 gets
> squeezed more towards the middle of the range from before.
>
> <unk$ src/netperf -H s9 -v 2 -l 30 -- -m 128K -s 128K -S 128K
> TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to s9.cup.hp.co=
m
> (16.89.132.29) port 0 AF_INET : histogram
> Recv =A0 Send =A0 =A0Send
> Socket Socket =A0Message =A0Elapsed
> Size =A0 Size =A0 =A0Size =A0 =A0 Time =A0 =A0 Throughput
> bytes =A0bytes =A0 bytes =A0 =A0secs. =A0 =A010^6bits/sec
>
> 262142 262144 131072 =A0 =A030.00 =A0 =A0 911.91
>
> Alignment =A0 =A0 =A0Offset =A0 =A0 =A0 =A0 Bytes =A0 =A0Bytes =A0 =A0=
 =A0 Sends =A0 Bytes =A0 =A0Recvs
> Local =A0Remote =A0Local =A0Remote =A0Xfered =A0 Per =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 Per
> Send =A0 Recv =A0 =A0Send =A0 Recv =A0 =A0 =A0 =A0 =A0 =A0 Send (avg)=
 =A0 =A0 =A0 =A0 =A0Recv (avg)
> =A0 =A08 =A0 =A0 =A0 8 =A0 =A0 =A00 =A0 =A0 =A0 0 3.42e+09 =A0131074.=
74 =A0 =A0 26091 =A0 11361.40 301008
>
> Maximum
> Segment
> Size (bytes)
> =A01448
>
>
> Histogram of time spent in send() call.
> UNIT_USEC =A0 =A0 : =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00:=
 =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00
> TEN_USEC =A0 =A0 =A0: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A0=
0: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00
> HUNDRED_USEC =A0: =A0 =A00: =A0401: =A0 64: =A0 10: =A0 =A00: =A0 =A0=
0: =A0 =A01: =A0279: 10237: 3914
> UNIT_MSEC =A0 =A0 : =A0 =A00: 11149: =A0 31: =A0 =A00: =A0 =A04: =A0 =
=A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00
> TEN_MSEC =A0 =A0 =A0: =A0 =A00: =A0 =A01: =A0 =A00: =A0 =A00: =A0 =A0=
0: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00
> HUNDRED_MSEC =A0: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0=
 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00
> UNIT_SEC =A0 =A0 =A0: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A0=
0: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00
> TEN_SEC =A0 =A0 =A0 : =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A0=
0: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00
>>100_SECS: 0
> HIST_TOTAL: =A0 =A0 =A026091
>
> happy benchmarking,
>
> rick jones
>
>
> Just for grins, netperf asking for 64K socket buffers:
>
> <unk$ src/netperf -H s9 -v 2 -l 30 -- -m 128K -s 64K -S 64K
> TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to s9.cup.hp.co=
m
> (16.89.132.29) port 0 AF_INET : histogram
> Recv =A0 Send =A0 =A0Send
> Socket Socket =A0Message =A0Elapsed
> Size =A0 Size =A0 =A0Size =A0 =A0 Time =A0 =A0 Throughput
> bytes =A0bytes =A0 bytes =A0 =A0secs. =A0 =A010^6bits/sec
>
> 131072 131072 131072 =A0 =A030.00 =A0 =A0 921.12
>
> Alignment =A0 =A0 =A0Offset =A0 =A0 =A0 =A0 Bytes =A0 =A0Bytes =A0 =A0=
 =A0 Sends =A0 Bytes =A0 =A0Recvs
> Local =A0Remote =A0Local =A0Remote =A0Xfered =A0 Per =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 Per
> Send =A0 Recv =A0 =A0Send =A0 Recv =A0 =A0 =A0 =A0 =A0 =A0 Send (avg)=
 =A0 =A0 =A0 =A0 =A0Recv (avg)
> =A0 =A08 =A0 =A0 =A0 8 =A0 =A0 =A00 =A0 =A0 =A0 0 3.454e+09 =A0131074=
=2E33 =A0 =A0 26354 =A0 11399.69 303020
>
> Maximum
> Segment
> Size (bytes)
> =A01448
>
>
> Histogram of time spent in send() call.
> UNIT_USEC =A0 =A0 : =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00:=
 =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00
> TEN_USEC =A0 =A0 =A0: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A0=
0: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00
> HUNDRED_USEC =A0: =A0 =A00: =A0 =A02: =A0 =A00: =A0 =A00: =A0 =A00: =A0=
 =A07: 2672: 1831: =A0 19: =A0 =A01
> UNIT_MSEC =A0 =A0 : =A0 =A00: 21811: =A0 =A06: =A0 =A00: =A0 =A04: =A0=
 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00
> TEN_MSEC =A0 =A0 =A0: =A0 =A00: =A0 =A01: =A0 =A00: =A0 =A00: =A0 =A0=
0: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00
> HUNDRED_MSEC =A0: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0=
 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00
> UNIT_SEC =A0 =A0 =A0: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A0=
0: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00
> TEN_SEC =A0 =A0 =A0 : =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A0=
0: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00: =A0 =A00
>>100_SECS: 0
> HIST_TOTAL: =A0 =A0 =A026354
>

I am not sure i understand your historgram output.  But what i am
getting from your message is that my buffer may be too big.  If i
reduce the buffer like you are saying down to 256K send buffer than
the code that checks if select or send should block:

 if ((atomic_read(&sk->sk_wmem_alloc) << 1) <=3D
sk->sk_sndbuf

Would only block waiting for space of 128 KB free as compared to 1 Meg
free in my example.

Therefore reducing the max time for send calls (in theory).

Is this what you are getting at?

Cheers,
Ivan
