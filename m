From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Using ethernet device as efficient small packet generator
Date: Wed, 22 Dec 2010 18:51:11 +0100
Message-ID: <1293040271.3027.284.camel@edumazet-laptop>
References: <e66c1ff20e095bcc3a9a678a9935dc7e.squirrel@www.liukuma.net>
	 <1293005302.4317.19.camel@edumazet-laptop>
	 <4A6A2125329CFD4D8CC40C9E8ABCAB9F249D5F3327@MILEXCH2.ds.jdsu.net>
	 <1293033558.3027.216.camel@edumazet-laptop>
	 <4A6A2125329CFD4D8CC40C9E8ABCAB9F249D5F33D3@MILEXCH2.ds.jdsu.net>
	 <1293038302.3027.281.camel@edumazet-laptop>
	 <4A6A2125329CFD4D8CC40C9E8ABCAB9F249D5F3457@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "juice@swagman.org" <juice@swagman.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jon Zhou <Jon.Zhou@jdsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:52598 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751919Ab0LVRvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Dec 2010 12:51:15 -0500
Received: by wwa36 with SMTP id 36so5541505wwa.1
        for <netdev@vger.kernel.org>; Wed, 22 Dec 2010 09:51:14 -0800 (PST)
In-Reply-To: <4A6A2125329CFD4D8CC40C9E8ABCAB9F249D5F3457@MILEXCH2.ds.jdsu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 22 d=C3=A9cembre 2010 =C3=A0 09:40 -0800, Jon Zhou a =C3=A9=
crit :
>=20
> -----Original Message-----
> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]=20
> Sent: Thursday, December 23, 2010 1:18 AM
> To: Jon Zhou
> Cc: juice@swagman.org; Stephen Hemminger; netdev@vger.kernel.org
> Subject: RE: Using ethernet device as efficient small packet generato=
r
>=20
>=20
> > PGDEV=3D/proc/net/pktgen/eth4
>=20
> You meant :  PGDEV=3D/proc/net/pktgen/kpktgend_0   ???
>=20
>=20
> With "PGDEV=3D/proc/net/pktgen/kpktgend_0", I can't pgset "queue_map_=
min 0"
> Only able to pgset "queue_map_min 0" with "PGDEV=3D/proc/net/pktgen/e=
th4"
>=20
> >   echo "Configuring $PGDEV"
> >  pgset "$COUNT"
> >  pgset "$CLONE_SKB"
> >  pgset "$PKT_SIZE"
> >  pgset "$DELAY"
> >  pgset "dst 10.10.11.2"=20
> >  pgset "queue_map_min 0"
> >  pgset "queue_map_max 7"
> >  pgset "dst_mac  00:04:23:08:91:dc"
> >=20
> > ->it is ok
> >=20
> >=20
> > Here is the top result, why only kpktgend_0 is running?
> > Eric,can you share the pktgen script? Thank you
>=20
> If you want to control several kpktgend you need to send each one of
> them a full pktgen script.
>=20
> PGDEV=3D/proc/net/pktgen/kpktgend_0
> script0
> PGDEV=3D/proc/net/pktgen/kpktgend_1
> script1
> PGDEV=3D/proc/net/pktgen/kpktgend_2
> script2
> PGDEV=3D/proc/net/pktgen/kpktgend_3
> script3
>=20
> but these kpktgend can not share the same device?
> i.e.
> I can't add the device again?
>=20
> PGDEV=3D/proc/net/pktgen/kpktgend_1
>  #echo "Removing all devices"
>  #pgset "rem_device_all"=20
>  #echo "Adding eth4"
>  pgset "add_device eth4"  =20
>  pgset "queue_map_min 1"
>  pgset "queue_map_max 1"
>=20
> as I saw when pps reach 1M, throughput reach 900Mbps,the kpktgend_0 a=
lso reach 100% cpu (with intel 10G X520 nic,ixgbe)
>=20
>=20

Please quote messages normally

You mix several things, please read :

http://www.spinics.net/lists/netdev/msg71164.html



