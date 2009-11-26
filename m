From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Strange CPU load when flushing route cache (kernel 2.6.31.6)
Date: Thu, 26 Nov 2009 12:05:07 +0100
Message-ID: <4B0E60E3.5040301@gmail.com>
References: <1258970332.29747.262.camel@jdb-workstation>	 <4B0A63FA.5000804@gmail.com> <1258979320.29747.270.camel@jdb-workstation>	 <4B0A8D41.6010608@gmail.com>	 <Pine.LNX.4.64.0911231437020.24347@ask.diku.dk>	 <4B0A9631.2030705@gmail.com> <1259232716.30983.101.camel@jdb-workstation>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	Robert Olsson <robert@herjulf.net>
To: Jesper Dangaard Brouer <jdb@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39175 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751944AbZKZLFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2009 06:05:08 -0500
In-Reply-To: <1259232716.30983.101.camel@jdb-workstation>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer a =C3=A9crit :
> On Mon, 2009-11-23 at 15:03 +0100, Eric Dumazet wrote:
>>> grep LowTotal /proc/meminfo
>>> LowTotal:         747080 kB
>>>
>>> What does that mean?  Is it bad? What should I run on a 32-bit
>>> system/kernel?
>> If you have more than 1GB of physical ram, and use your machine as a=
 router, you might
>> compile a 2GB/2GB User/Kernel kernel, to get twice available RAM for=
 kernel
>> and more IP route entries (if needed)
>=20
> Can I still use this option if the machine "only" have 2G of physical
> RAM?  Most of my production machines have 2G RAM.
>=20
> Just to verify: This is not an issue on 64-bit kernels right?


If your kernel is 32bit, and you have 2GB of ram, then selecting a 2G/2=
G split
allows your kernel to use more ram (This is called LOWMEM.

Yes, this not an issue on 64bits kernels : All RAM is LOWMEM :)


>=20
>> make menuconfig
>> --> Processor type and features
>>   --> Memory split
>>     --> 2G/2G
>=20
> For completeness sake, Memory split depends on "if EMBEDDED"
>=20
> So I also needed to enable:
>=20
>  make menuconfig
>   --> General setup
>      --> Configure standard kernel features (for small systems)=20
>=20
>=20
>>> Can you recommend any other /proc/sys/ tuning options?
>> Really hard to say without exact context of use :)
>=20
> The machines does Internet traffic routing, but with a VERY large
> iptables rulesets, e.g. on one production machine I have 18409 chains
> and 62916 iptables rules. (I did most of the scalability patches to
> iptables userspace to make this work...). And the machines also uses =
a
> very large HTB tree.  Basically I do, per customer, Access Control,
> Bandwidth limiting and Personal firewall.
>=20
> Also note that I'm reserving extra vmalloc memory as iptables uses
> vmalloc'ed memory...


>=20
> Okay I'll keep boot parameter then... or is it possible to resize the
> hash runtime?

Nope, we use RCU lookups, so a resize would be complex.

