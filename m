From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: TCP communication for raw image transmission
Date: Thu, 5 Jan 2012 10:13:32 +0100
Message-ID: <CAL8zT=iSP+GncMEJ38eaCZ85P-tBDMUjUeaFr-x3j_rksUaK2A@mail.gmail.com>
References: <CAL8zT=iSiKZfENdtng9gDtuRSuFNn4WZ69uuGapLVVEduFRVyQ@mail.gmail.com>
 <1325519943.2375.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CAL8zT=giNe46FYQYxPkbshVfyG-DvCTKS0RLdiN8Kz+e-x-JFw@mail.gmail.com>
 <1325521745.18116.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CAL8zT=gbCmtNpw1Lot0P7zB+b_Kw911jhxsXCzO3JOBmMLRcFg@mail.gmail.com>
 <1325523137.18116.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <4F0382BB.5060601@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:41068 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753607Ab2AEJNy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 04:13:54 -0500
Received: by werm1 with SMTP id m1so201854wer.19
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2012 01:13:53 -0800 (PST)
In-Reply-To: <4F0382BB.5060601@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/3 Rick Jones <rick.jones2@hp.com>:
> On 01/02/2012 08:52 AM, Eric Dumazet wrote:
>>
>> Le lundi 02 janvier 2012 =C3=A0 17:40 +0100, Jean-Michel Hautbois a =
=C3=A9crit :
>>
>>> Mmmh, using netperf you would like to know what the client (my ARM
>>> board) can do ?
>>> How would you test it ? I can have an ARM board on one side, and th=
e
>>> x86 on the other...
>>>
>>
>> x86> =C2=A0netserver&
>> arm> =C2=A0netperf -H<arm_ip_address> =C2=A0-l 60 -t TCP_STREAM
>>
>> 1) check cpu usage on<arm> =C2=A0while test is running
>> (for example : vmstat 1 )
>> 2) check bandwith of test run
>
>
> The "&" at the end of the netserver command is (should be) redundant =
-
> netserver will by default daemonize itself.
>
> I would suggest amending the netperf command line to something more l=
ike:
>
> netperf -H <x86IP> -c -l 60 -t TCP_STREAM -- -m <dataofoneline> -D

I did it, and here are the results (when plugged directly between x86
and arm, and not throught the switch, as before) :
/ # netperf -H 192.168.0.1 -c -l 60 -t TCP_STREAM -- -m 1344 -D
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

 87380  16384   1344    60.01        45.43   100.00   -1.00    180.325 =
 -1.000

And without specifying the data size :
/ # netperf -H 192.168.0.1 -c -l 60 -t TCP_STREAM
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.0.1 (192.168.0.1) port 0 AF_INET
Recv   Send    Send                          Utilization       Service =
Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    =
Recv
Size   Size    Size     Time     Throughput  local    remote   local   =
remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   =
us/KB

 87380  16384  16384    60.01        61.94   99.98    -1.00    132.230 =
 -1.000

This is far better than the first tests, but this means my best bet is
to send as much data as possible (here, 16384)...
I will do a benchmark with a little script which will test several
frame sizes (or is there a way to know the theorical better value ?).

JM
