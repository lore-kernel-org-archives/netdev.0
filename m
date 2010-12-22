From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Using ethernet device as efficient small packet generator
Date: Wed, 22 Dec 2010 16:59:18 +0100
Message-ID: <1293033558.3027.216.camel@edumazet-laptop>
References: <e66c1ff20e095bcc3a9a678a9935dc7e.squirrel@www.liukuma.net>
	 <1293005302.4317.19.camel@edumazet-laptop>
	 <4A6A2125329CFD4D8CC40C9E8ABCAB9F249D5F3327@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "juice@swagman.org" <juice@swagman.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jon Zhou <Jon.Zhou@jdsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51443 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752686Ab0LVP7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Dec 2010 10:59:22 -0500
Received: by wwa36 with SMTP id 36so5427392wwa.1
        for <netdev@vger.kernel.org>; Wed, 22 Dec 2010 07:59:21 -0800 (PST)
In-Reply-To: <4A6A2125329CFD4D8CC40C9E8ABCAB9F249D5F3327@MILEXCH2.ds.jdsu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 22 d=C3=A9cembre 2010 =C3=A0 07:48 -0800, Jon Zhou a =C3=A9=
crit :
>=20

> Hi eric, any special setting in pktgen.conf?
>=20
> PGDEV=3D/proc/net/pktgen/kpktgend_0
>   echo "Removing all devices"
>  pgset "rem_device_all"
>   echo "Adding eth1-fp-0" //or eth1?

eth1

>  pgset "add_device eth1"
>   echo "Setting max_before_softirq 10000"
>  pgset "max_before_softirq 10000"

Not sure you need to tweak max_before_softirq (I never did)

>=20
> All things I need to do is set cpu affinity and start 8 pktgen thread=
s? (PGDEV=3D/proc/net/pktgen/kpktgend_0~7 with "eth1")

Yes, but you must also use queue_map_min and queue_map_max pktgen
parameters so that each cpu manipulates its own 'queue'

CPU 0 :=20

   pgset "queue_map_min 0"
   pgset "queue_map_max 0"

=2E..

CPU 3 :=20

   pgset "queue_map_min 3"
   pgset "queue_map_max 3"




