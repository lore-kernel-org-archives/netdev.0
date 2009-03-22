From: Jesper Krogh <jesper@krogh.cc>
Subject: Re: Status update on Sun Neptune 10Gbit fibre using the NIU-driver.
Date: Sun, 22 Mar 2009 17:39:36 +0100
Message-ID: <49C669C8.70902@krogh.cc>
References: <49C600CE.70704@krogh.cc> <49C65AFC.3080300@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:36250 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752065AbZCVQjj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Mar 2009 12:39:39 -0400
In-Reply-To: <49C65AFC.3080300@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Jesper Krogh a =E9crit :
>> Hi.
>>
>> Back in the 2.6.25/26-days .. (around 9 months ago) I had som stuggl=
es
>> getting both performance and stabillity out of a Sun Neptune 10Gbit =
NIC
>> over fibre. The NIU driver blew up on the system under load but Math=
eos
>> Worku send me an internal Sun driver (nxge) that performed fairly we=
ll.
>> It peaked out around 800-850 MB/s .. it put a fairly high load on th=
e
>> host system and peaked with over 300.000 cs/s (both numbers measured
>> with dstat).
>>
>> Today I got around to tesing the NIU(2.6.27.20) driver again. Having
>> repeated the test I did last summer I couldn't get it to "blow up". =
But
>> instead of the ~500MB/s i got out of it last summer, it peaks at 940=
MB/s
>> now and the load on the host is nearly invisible (<2) .. cs rates le=
ss
>> than 10K mostly.
>>
>> I'm not using any kind of Jumbo frames in the setup.
>>
>> I'll keep it up on the niu-driver for now and report back if it
>> encounters any problems.
>>
>> In the test .. I do dd over NFS, default exports, default mount opti=
ons
>> .. dd have "bs" set to either 1M or to 512 (to try to stress the NFS
>> server). I have tried to put cpu-load in the NFS-server while runnin=
g
>> the NFS-server and pushing some data around on them memory subsystem
>> while doing it.
>>
>> This is just excellent..  (crossing fingers that it can beat the 180
>> days of uptime the nxge-driver got).
>>
>> Link to old struggles:
>> http://thread.gmane.org/gmane.linux.kernel/677545
>>
>> Jesper
>=20
> Yes I remember this stuff. David added multi tx queue support in last=
 July
> (for 2.6.27)

Can there be something about "fairness" changed? While producing the=20
screenshot to you below I got this one on the server:
do_ypcall: clnt_call: RPC: Unable to send; errno =3D No buffer space av=
ailable

So NIS wasn't able to get throgh..

> Could you post more information please, about load on individual cpus
>  for example ? (top snapshot with one line per cpu)

http://krogh.cc/~jesper/top.png

> Is NFS using TCP or UDP on your setup ?

TCP.

> An interesting test would be the reverse path (transmit from clients =
to
> this server)

Thats harder to setup and not be "disk IO-bound on the server". Perhaps=
=20
exporting a RAM-disk and write into that?

> Also, testing 2.6.29 could be interesting, since UDP receive
> path doesnt need to use a global rwlock anymore.

I'll put that on my todo list..

--=20
Jesper
