From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: Re: e1000 performance issue in 4 simultaneous links
Date: Fri, 11 Jan 2008 16:19:41 -0200
Message-ID: <1200075581.9349.33.camel@cafe>
References: <1199981839.8931.35.camel@cafe>
	 <36D9DB17C6DE9E40B059440DB8D95F5204275B04@orsmsx418.amr.corp.intel.com>
	 <1200068444.9349.20.camel@cafe>  <47879DE4.8080603@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	rick.jones2@hp.com, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw2.br.ibm.com ([32.104.18.25]:57792 "EHLO igw2.br.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754917AbYAKSTw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2008 13:19:52 -0500
Received: from mailhub1.br.ibm.com (mailhub1 [9.18.232.109])
	by igw2.br.ibm.com (Postfix) with ESMTP id D452B17F4DE
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 16:14:06 -0200 (BRDT)
Received: from d24av02.br.ibm.com (d24av02.br.ibm.com [9.18.232.47])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0BIJiOv3661872
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 16:19:47 -0200
Received: from d24av02.br.ibm.com (loopback [127.0.0.1])
	by d24av02.br.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0BIJi2C016087
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 16:19:44 -0200
In-Reply-To: <47879DE4.8080603@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-01-11 at 17:48 +0100, Eric Dumazet wrote:
> Breno Leitao a =C3=A9crit :
> > Take a look at the interrupt table this time:=20
> >
> > io-dolphins:~/leitao # cat /proc/interrupts  | grep eth[1]*[67]
> > 277:         15    1362450         13         14         13        =
 14         15         18   XICS      Level     eth6
> > 278:         12         13    1348681         19         13        =
 15         10         11   XICS      Level     eth7
> > 323:         11         18         17    1348426         18        =
 11         11         13   XICS      Level     eth16
> > 324:         12         16         11         19    1402709        =
 13         14         11   XICS      Level     eth17
> >
> >
> >  =20
> If your machine has 8 cpus, then your vmstat output shows a bottlenec=
k :)
>=20
> (100/8 =3D 12.5), so I guess one of your CPU is full

Well, if I run top while running the test, I see this load distributed
among the CPUs, mainly those that had a NIC IRC bonded. Take a look:

Tasks: 133 total,   2 running, 130 sleeping,   0 stopped,   1 zombie
Cpu0  :  0.3%us, 19.5%sy,  0.0%ni, 73.5%id,  0.0%wa,  0.0%hi,  0.0%si, =
 6.6%st
Cpu1  :  0.0%us,  0.0%sy,  0.0%ni, 75.1%id,  0.0%wa,  0.7%hi, 24.3%si, =
 0.0%st
Cpu2  :  0.0%us,  0.0%sy,  0.0%ni, 73.1%id,  0.0%wa,  0.7%hi, 26.2%si, =
 0.0%st
Cpu3  :  0.0%us,  0.0%sy,  0.0%ni, 76.1%id,  0.0%wa,  0.7%hi, 23.3%si, =
 0.0%st
Cpu4  :  0.0%us,  0.3%sy,  0.0%ni, 70.4%id,  0.7%wa,  0.3%hi, 28.2%si, =
 0.0%st
Cpu5  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si, =
 0.0%st
Cpu6  :  0.0%us,  0.0%sy,  0.0%ni, 99.7%id,  0.0%wa,  0.0%hi,  0.3%si, =
 0.0%st
Cpu7  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si, =
 0.0%st

Note that this average scenario doesn't change during the entire
benchmarking test.

Thanks!

--=20
Breno Leitao <leitao@linux.vnet.ibm.com>

