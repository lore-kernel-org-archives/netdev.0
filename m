From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Status update on Sun Neptune 10Gbit fibre using the NIU-driver.
Date: Sun, 22 Mar 2009 16:36:28 +0100
Message-ID: <49C65AFC.3080300@cosmosbay.com>
References: <49C600CE.70704@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesper Krogh <jesper@krogh.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38400 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754131AbZCVPgj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2009 11:36:39 -0400
In-Reply-To: <49C600CE.70704@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Krogh a =E9crit :
> Hi.
>=20
> Back in the 2.6.25/26-days .. (around 9 months ago) I had som stuggle=
s
> getting both performance and stabillity out of a Sun Neptune 10Gbit N=
IC
> over fibre. The NIU driver blew up on the system under load but Mathe=
os
> Worku send me an internal Sun driver (nxge) that performed fairly wel=
l.
> It peaked out around 800-850 MB/s .. it put a fairly high load on the
> host system and peaked with over 300.000 cs/s (both numbers measured
> with dstat).
>=20
> Today I got around to tesing the NIU(2.6.27.20) driver again. Having
> repeated the test I did last summer I couldn't get it to "blow up". B=
ut
> instead of the ~500MB/s i got out of it last summer, it peaks at 940M=
B/s
> now and the load on the host is nearly invisible (<2) .. cs rates les=
s
> than 10K mostly.
>=20
> I'm not using any kind of Jumbo frames in the setup.
>=20
> I'll keep it up on the niu-driver for now and report back if it
> encounters any problems.
>=20
> In the test .. I do dd over NFS, default exports, default mount optio=
ns
> .. dd have "bs" set to either 1M or to 512 (to try to stress the NFS
> server). I have tried to put cpu-load in the NFS-server while running
> the NFS-server and pushing some data around on them memory subsystem
> while doing it.
>=20
> This is just excellent..  (crossing fingers that it can beat the 180
> days of uptime the nxge-driver got).
>=20
> Link to old struggles:
> http://thread.gmane.org/gmane.linux.kernel/677545
>=20
> Jesper

Yes I remember this stuff. David added multi tx queue support in last J=
uly
(for 2.6.27)

Could you post more information please, about load on individual cpus
 for example ? (top snapshot with one line per cpu)

Is NFS using TCP or UDP on your setup ?

An interesting test would be the reverse path (transmit from clients to
this server)

Also, testing 2.6.29 could be interesting, since UDP receive
path doesnt need to use a global rwlock anymore.

