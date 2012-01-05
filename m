From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP communication for raw image transmission
Date: Thu, 05 Jan 2012 10:32:58 -0800
Message-ID: <4F05ECDA.30506@hp.com>
References: <CAL8zT=iSiKZfENdtng9gDtuRSuFNn4WZ69uuGapLVVEduFRVyQ@mail.gmail.com> <1325519943.2375.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CAL8zT=giNe46FYQYxPkbshVfyG-DvCTKS0RLdiN8Kz+e-x-JFw@mail.gmail.com> <1325521745.18116.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CAL8zT=gbCmtNpw1Lot0P7zB+b_Kw911jhxsXCzO3JOBmMLRcFg@mail.gmail.com> <1325523137.18116.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <4F0382BB.5060601@hp.com> <CAL8zT=iSP+GncMEJ38eaCZ85P-tBDMUjUeaFr-x3j_rksUaK2A@mail.gmail.com> <1325756410.2415.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CAL8zT=jyzV6BwB6Lce0CCi+Z3MuwNsWLw2DQu8HBdm_J8kvArA@mail.gmail.com> <1325757343.2415.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jean-Michel Hautbois <jhautbois@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:33398 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755186Ab2AESdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 13:33:00 -0500
In-Reply-To: <1325757343.2415.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/05/2012 01:55 AM, Eric Dumazet wrote:
> Le jeudi 05 janvier 2012 =C3=A0 10:48 +0100, Jean-Michel Hautbois a =C3=
=A9crit :
>
>> It does not seem to work :
>> netperf -H 192.168.0.1 -l 10 -t UDP_STREAM
>> MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
>> 192.168.0.1 (192.168.0.1) port 0 AF_INET
>> Socket  Message  Elapsed      Messages
>> Size    Size     Time         Okay Errors   Throughput
>> bytes   bytes    secs            #      #   10^6bits/sec
>>
>> 106496   65507   10.01        1836      0       0.00
>> 419227124           0.00      536870912              0.00
>>
>
> Thats because netperf -t UDP_STREAM sends big UDP frames by default,
> that must be fragmented, and defragmented on destination. Maybe some
> frags are lost.

There is also the question of the bogus values on the second line.=20
There are some "fixed in top-of-trunk" issues in that area with respect=
=20
to the migrated UDP_STREAM results printing.  The top of trunk also has=
=20
a netperf control message size change, which means you have to make sur=
e=20
to update both sides to the top-of-trunk.  (Netperf has never=20
"supported" mixing versions though doing so has often "worked.")

rick jones
