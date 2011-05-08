From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Scalability of interface creation and deletion
Date: Sun, 08 May 2011 09:12:22 +0200
Message-ID: <1304838742.3207.45.camel@edumazet-laptop>
References: <891B02256A0667292521A4BF@Ximines.local>
	 <1304770926.2821.1157.camel@edumazet-laptop>
	 <0F4A638C2A523577CDBC295E@Ximines.local>
	 <1304785589.3207.5.camel@edumazet-laptop>
	 <178E8895FB84C07251538EF7@Ximines.local>
	 <1304793174.3207.22.camel@edumazet-laptop>
	 <1304793749.3207.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Alex Bligh <alex@alex.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43918 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751361Ab1EHHM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 03:12:27 -0400
Received: by wwa36 with SMTP id 36so4762536wwa.1
        for <netdev@vger.kernel.org>; Sun, 08 May 2011 00:12:26 -0700 (PDT)
In-Reply-To: <1304793749.3207.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 07 mai 2011 =C3=A0 20:42 +0200, Eric Dumazet a =C3=A9crit :
> Here is my trace here for one device deletion on one 8 core machine
>=20
> [  800.447012] synchronize_rcu() in 15787 us
> [  800.455013] synchronize_rcu() in 7682 us
> [  800.464019] rcu_barrier() in 8487 us
>=20
> Not that bad.
>=20
> $ grep RCU .config
> # RCU Subsystem
> CONFIG_TREE_RCU=3Dy
> # CONFIG_PREEMPT_RCU is not set
> CONFIG_RCU_TRACE=3Dy
> CONFIG_RCU_FANOUT=3D32
> # CONFIG_RCU_FANOUT_EXACT is not set
> # CONFIG_RCU_FAST_NO_HZ is not set
> CONFIG_TREE_RCU_TRACE=3Dy
>=20

By the way, if I change HZ from 1000 to 100 I now have ten times slower
result :

# ip link add link eth0 eth0.103 type vlan id 103
# time ip link del eth0.103

real	0m0.430s
user	0m0.000s
sys	0m0.000s

So all this is related to your HZ value, even in a CONFIG_NO_HZ=3Dy
kernel. Alex, I guess you have HZ=3D250 ?

# uname -a
Linux svivoipvnx021 2.6.39-rc6-00214-g5511a34-dirty #574 SMP Sun May 8
08:44:14 CEST 2011 x86_64 x86_64 x86_64 GNU/Linux
# cat /proc/cmdline

I enabled CONFIG_RCU_FAST_NO_HZ and got worse results (but not
alsways... its very variable)

# time ip link del eth0.103

real	0m0.544s
user	0m0.000s
sys	0m0.000s


# time ip link del eth0.103

real	0m0.414s
user	0m0.000s
sys	0m0.000s


