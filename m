From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: TCP communication for raw image transmission
Date: Thu, 5 Jan 2012 10:48:25 +0100
Message-ID: <CAL8zT=jyzV6BwB6Lce0CCi+Z3MuwNsWLw2DQu8HBdm_J8kvArA@mail.gmail.com>
References: <CAL8zT=iSiKZfENdtng9gDtuRSuFNn4WZ69uuGapLVVEduFRVyQ@mail.gmail.com>
 <1325519943.2375.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CAL8zT=giNe46FYQYxPkbshVfyG-DvCTKS0RLdiN8Kz+e-x-JFw@mail.gmail.com>
 <1325521745.18116.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CAL8zT=gbCmtNpw1Lot0P7zB+b_Kw911jhxsXCzO3JOBmMLRcFg@mail.gmail.com>
 <1325523137.18116.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <4F0382BB.5060601@hp.com> <CAL8zT=iSP+GncMEJ38eaCZ85P-tBDMUjUeaFr-x3j_rksUaK2A@mail.gmail.com>
 <1325756410.2415.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:54944 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751247Ab2AEJsr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 04:48:47 -0500
Received: by werm1 with SMTP id m1so221026wer.19
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2012 01:48:46 -0800 (PST)
In-Reply-To: <1325756410.2415.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/5 Eric Dumazet <eric.dumazet@gmail.com>:
> Le jeudi 05 janvier 2012 =C3=A0 10:13 +0100, Jean-Michel Hautbois a =C3=
=A9crit :
>> 2012/1/3 Rick Jones <rick.jones2@hp.com>:
>> > On 01/02/2012 08:52 AM, Eric Dumazet wrote:
>> >>
>> >> Le lundi 02 janvier 2012 =C3=A0 17:40 +0100, Jean-Michel Hautbois=
 a =C3=A9crit :
>> >>
>> >>> Mmmh, using netperf you would like to know what the client (my A=
RM
>> >>> board) can do ?
>> >>> How would you test it ? I can have an ARM board on one side, and=
 the
>> >>> x86 on the other...
>> >>>
>> >>
>> >> x86> =C2=A0netserver&
>> >> arm> =C2=A0netperf -H<arm_ip_address> =C2=A0-l 60 -t TCP_STREAM
>> >>
>> >> 1) check cpu usage on<arm> =C2=A0while test is running
>> >> (for example : vmstat 1 )
>> >> 2) check bandwith of test run
>> >
>> >
>> > The "&" at the end of the netserver command is (should be) redunda=
nt -
>> > netserver will by default daemonize itself.
>> >
>> > I would suggest amending the netperf command line to something mor=
e like:
>> >
>> > netperf -H <x86IP> -c -l 60 -t TCP_STREAM -- -m <dataofoneline> -D
>>
>> I did it, and here are the results (when plugged directly between x8=
6
>> and arm, and not throught the switch, as before) :
>> / # netperf -H 192.168.0.1 -c -l 60 -t TCP_STREAM -- -m 1344 -D
>> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
>> 192.168.0.1 (192.168.0.1) port 0 AF_INET : nodelay
>> Recv =C2=A0 Send =C2=A0 =C2=A0Send =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Utilization =C2=
=A0 =C2=A0 =C2=A0 Service Demand
>> Socket Socket =C2=A0Message =C2=A0Elapsed =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0Send =C2=A0 =C2=A0 Recv =C2=A0 =C2=A0 Send =C2=A0 =
=C2=A0Recv
>> Size =C2=A0 Size =C2=A0 =C2=A0Size =C2=A0 =C2=A0 Time =C2=A0 =C2=A0 =
Throughput =C2=A0local =C2=A0 =C2=A0remote =C2=A0 local =C2=A0 remote
>> bytes =C2=A0bytes =C2=A0 bytes =C2=A0 =C2=A0secs. =C2=A0 =C2=A010^6b=
its/s =C2=A0% S =C2=A0 =C2=A0 =C2=A0% U =C2=A0 =C2=A0 =C2=A0us/KB =C2=A0=
 us/KB
>>
>> =C2=A087380 =C2=A016384 =C2=A0 1344 =C2=A0 =C2=A060.01 =C2=A0 =C2=A0=
 =C2=A0 =C2=A045.43 =C2=A0 100.00 =C2=A0 -1.00 =C2=A0 =C2=A0180.325 =C2=
=A0-1.000
>>
>> And without specifying the data size :
>> / # netperf -H 192.168.0.1 -c -l 60 -t TCP_STREAM
>> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
>> 192.168.0.1 (192.168.0.1) port 0 AF_INET
>> Recv =C2=A0 Send =C2=A0 =C2=A0Send =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Utilization =C2=
=A0 =C2=A0 =C2=A0 Service Demand
>> Socket Socket =C2=A0Message =C2=A0Elapsed =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0Send =C2=A0 =C2=A0 Recv =C2=A0 =C2=A0 Send =C2=A0 =
=C2=A0Recv
>> Size =C2=A0 Size =C2=A0 =C2=A0Size =C2=A0 =C2=A0 Time =C2=A0 =C2=A0 =
Throughput =C2=A0local =C2=A0 =C2=A0remote =C2=A0 local =C2=A0 remote
>> bytes =C2=A0bytes =C2=A0 bytes =C2=A0 =C2=A0secs. =C2=A0 =C2=A010^6b=
its/s =C2=A0% S =C2=A0 =C2=A0 =C2=A0% U =C2=A0 =C2=A0 =C2=A0us/KB =C2=A0=
 us/KB
>>
>> =C2=A087380 =C2=A016384 =C2=A016384 =C2=A0 =C2=A060.01 =C2=A0 =C2=A0=
 =C2=A0 =C2=A061.94 =C2=A0 99.98 =C2=A0 =C2=A0-1.00 =C2=A0 =C2=A0132.23=
0 =C2=A0-1.000
>>
>> This is far better than the first tests, but this means my best bet =
is
>> to send as much data as possible (here, 16384)...
>> I will do a benchmark with a little script which will test several
>> frame sizes (or is there a way to know the theorical better value ?)=
=2E
>>

Here is the result of this little benchmark :
m=3D1024
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.0.1 (192.168.0.1) port 0 AF_INET : nodelay
Recv   Send    Send                          Utilization       Service =
Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    =
Recv
Size   Size    Size     Time     Throughput  local    remote   local   =
remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   =
us/KB

 87380  16384   1024    60.01        36.44   99.97    -1.00    224.722 =
 -1.000

m=3D1344
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.0.1 (192.168.0.1) port 0 AF_INET : nodelay
Recv   Send    Send                          Utilization       Service =
Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    =
Recv
Size   Size    Size     Time     Throughput  local    remote   local   =
remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   =
us/KB

 87380  16384   1344    60.01        45.95   100.00   -1.00    178.279 =
 -1.000

m=3D1460
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.0.1 (192.168.0.1) port 0 AF_INET : nodelay
Recv   Send    Send                          Utilization       Service =
Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    =
Recv
Size   Size    Size     Time     Throughput  local    remote   local   =
remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   =
us/KB

 87380  16384   1460    60.01        27.92   99.98    -1.00    293.382 =
 -1.000

m=3D2048
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.0.1 (192.168.0.1) port 0 AF_INET : nodelay
Recv   Send    Send                          Utilization       Service =
Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    =
Recv
Size   Size    Size     Time     Throughput  local    remote   local   =
remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   =
us/KB

 87380  16384   2048    60.01        38.15   99.98    -1.00    214.705 =
 -1.000

m=3D4096
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.0.1 (192.168.0.1) port 0 AF_INET : nodelay
Recv   Send    Send                          Utilization       Service =
Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    =
Recv
Size   Size    Size     Time     Throughput  local    remote   local   =
remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   =
us/KB

 87380  16384   4096    60.01        55.32   99.98    -1.00    148.070 =
 -1.000

m=3D8192
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.0.1 (192.168.0.1) port 0 AF_INET : nodelay
Recv   Send    Send                          Utilization       Service =
Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    =
Recv
Size   Size    Size     Time     Throughput  local    remote   local   =
remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   =
us/KB

 87380  16384   8192    60.01        62.06   100.00   -1.00    132.000 =
 -1.000

m=3D16384
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.0.1 (192.168.0.1) port 0 AF_INET : nodelay
Recv   Send    Send                          Utilization       Service =
Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    =
Recv
Size   Size    Size     Time     Throughput  local    remote   local   =
remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   =
us/KB

 87380  16384  16384    60.01        63.07   99.98    -1.00    129.865 =
 -1.000

m=3D32768
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.0.1 (192.168.0.1) port 0 AF_INET : nodelay
Recv   Send    Send                          Utilization       Service =
Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    =
Recv
Size   Size    Size     Time     Throughput  local    remote   local   =
remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   =
us/KB

 87380  16384  32768    60.01        67.46   100.00   -1.00    121.428 =
 -1.000

m is the size of the message, and there is clearly an effect of this va=
lue...

> Could you test UDP_STREAM as well ?
>
> $ netperf -H 192.168.0.1 -l 10 -t UDP_STREAM
> UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
> 192.168.0.1 (192.168.0.1) port 0 AF_INET
> Socket =C2=A0Message =C2=A0Elapsed =C2=A0 =C2=A0 =C2=A0Messages
> Size =C2=A0 =C2=A0Size =C2=A0 =C2=A0 Time =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 Okay Errors =C2=A0 Throughput
> bytes =C2=A0 bytes =C2=A0 =C2=A0secs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0# =C2=A0 =C2=A0 =C2=A0# =C2=A0 10^6bits/sec
>
> 1000000 =C2=A0 65507 =C2=A0 10.00 =C2=A0 =C2=A0 =C2=A0 13398 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 702.12
> 110592 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 10.00 =C2=A0 =C2=A0 =C2=A0 =
13398 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0702.12

It does not seem to work :
netperf -H 192.168.0.1 -l 10 -t UDP_STREAM
MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.0.1 (192.168.0.1) port 0 AF_INET
Socket  Message  Elapsed      Messages
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

106496   65507   10.01        1836      0       0.00
419227124           0.00      536870912              0.00

Adding a "-c" gives the same :
netperf -H 192.168.0.1 -c -l 10 -t UDP_STREAM
MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.0.1 (192.168.0.1) port 0 AF_INET
Socket  Message  Elapsed      Messages                   CPU      Servi=
ce
Size    Size     Time         Okay Errors   Throughput   Util     Deman=
d
bytes   bytes    secs            #      #   10^6bits/sec % SU     us/KB

106496   65507   10.01        1835      0        0.0     96.10    50.25=
0
536870912           2.25      1073741824               0.0     96.10   =
 -1.000

Using ifconfig before and after and comparing the TX values I get 98Mbp=
s...

> Then, a pktgen test (this sends UDP frames, but from kernel land) mig=
ht
> give you the limit of the NIC...

I need to recompile my kernel, as I don't have the CONFIG_NET_PKTGEN
in this one...
JM
