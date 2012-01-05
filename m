From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: TCP communication for raw image transmission
Date: Thu, 5 Jan 2012 10:57:38 +0100
Message-ID: <CAL8zT=hGnnuXf+cETy9fAeu+aACp2pfL3XfBS_jL_mk38fj4yQ@mail.gmail.com>
References: <CAL8zT=iSiKZfENdtng9gDtuRSuFNn4WZ69uuGapLVVEduFRVyQ@mail.gmail.com>
 <1325519943.2375.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CAL8zT=giNe46FYQYxPkbshVfyG-DvCTKS0RLdiN8Kz+e-x-JFw@mail.gmail.com>
 <1325521745.18116.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CAL8zT=gbCmtNpw1Lot0P7zB+b_Kw911jhxsXCzO3JOBmMLRcFg@mail.gmail.com>
 <1325523137.18116.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <4F0382BB.5060601@hp.com> <CAL8zT=iSP+GncMEJ38eaCZ85P-tBDMUjUeaFr-x3j_rksUaK2A@mail.gmail.com>
 <1325756410.2415.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CAL8zT=jyzV6BwB6Lce0CCi+Z3MuwNsWLw2DQu8HBdm_J8kvArA@mail.gmail.com> <1325757343.2415.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:57953 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753012Ab2AEJ6A convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 04:58:00 -0500
Received: by wgbds13 with SMTP id ds13so399865wgb.1
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2012 01:57:59 -0800 (PST)
In-Reply-To: <1325757343.2415.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/5 Eric Dumazet <eric.dumazet@gmail.com>:
> Le jeudi 05 janvier 2012 =C3=A0 10:48 +0100, Jean-Michel Hautbois a =C3=
=A9crit :
>
>> It does not seem to work :
>> netperf -H 192.168.0.1 -l 10 -t UDP_STREAM
>> MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
>> 192.168.0.1 (192.168.0.1) port 0 AF_INET
>> Socket =C2=A0Message =C2=A0Elapsed =C2=A0 =C2=A0 =C2=A0Messages
>> Size =C2=A0 =C2=A0Size =C2=A0 =C2=A0 Time =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 Okay Errors =C2=A0 Throughput
>> bytes =C2=A0 bytes =C2=A0 =C2=A0secs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0# =C2=A0 =C2=A0 =C2=A0# =C2=A0 10^6bits/sec
>>
>> 106496 =C2=A0 65507 =C2=A0 10.01 =C2=A0 =C2=A0 =C2=A0 =C2=A01836 =C2=
=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 0.00
>> 419227124 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0.00 =C2=A0 =C2=A0 =C2=A0=
536870912 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00.00
>>
>
> Thats because netperf -t UDP_STREAM sends big UDP frames by default,
> that must be fragmented, and defragmented on destination. Maybe some
> frags are lost.
>
> Try :
>
> netperf -H 192.168.0.1 -l 10 -t UDP_STREAM -- -m 1500
>
>

/ # netperf -H 192.168.0.1 -c -l 10 -t UDP_STREAM -- -m 1500
MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.0.1 (192.168.0.1) port 0 AF_INET
Socket  Message  Elapsed      Messages                   CPU      Servi=
ce
Size    Size     Time         Okay Errors   Throughput   Util     Deman=
d
bytes   bytes    secs            #      #   10^6bits/sec % SU     us/KB

106496    1500   10.00       54477      0        0.0     65.34    100.0=
00
1073741824           2.25            0               0.0     65.34    -=
1.000

/ # netperf -H 192.168.0.1 -c -l 10 -t UDP_STREAM -- -m 1400
MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.0.1 (192.168.0.1) port 0 AF_INET
Socket  Message  Elapsed      Messages                   CPU      Servi=
ce
Size    Size     Time         Okay Errors   Throughput   Util     Deman=
d
bytes   bytes    secs            #      #   10^6bits/sec % SU     us/KB

106496    1400   10.00       73591      0        0.0     82.38    100.0=
00
-2147483648           2.25      1610612736               0.0     82.38 =
   -1.000

I will recompile my kernel in order to use perf as well, in order to
get profiling in the TCP case...
JM
