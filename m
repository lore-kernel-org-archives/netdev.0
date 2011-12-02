From: Michal Soltys <soltys@ziu.info>
Subject: Re: ebtables on a stick
Date: Fri, 02 Dec 2011 16:40:13 +0100
Message-ID: <4ED8F15D.8020909@ziu.info>
References: <925A849792280C4E80C5461017A4B8A2A04879@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0487A@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0487F@mail733.InfraSupportEtc.com> <20111128143901.GA589422@jupiter.n2.diac24.net> <4ED566A8.2000108@ziu.info> <925A849792280C4E80C5461017A4B8A2A048F6@mail733.InfraSupportEtc.com> <20111201071456.GJ589422@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A048F8@mail733.InfraSupportEtc.com> <20111201144745.GK589422@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A048F9@mail733.InfraSupportEtc.com> <20111201165040.GL589422@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A048FA@mail733.InfraSupportEtc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org
To: Greg Scott <GregScott@Infrasupport.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([80.72.38.138]:1125 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754713Ab1LBPkM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Dec 2011 10:40:12 -0500
In-Reply-To: <925A849792280C4E80C5461017A4B8A2A048FA@mail733.InfraSupportEtc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11-12-01 17:56, Greg Scott wrote:
>>  # ip -4 a l eth0; ip r l match 0.0.0.0; ip r l exact 10.255.255.1
>>  2: eth0:<BROADCAST,MULTICAST,UP,LOWER_UP>  mtu 1500 qdisc pfifo_fast
>>  state UNKNOWN qlen 1000
>>      inet 87.106.131.203/32 scope global eth0
>>  default via 10.255.255.1 dev eth0
>>  10.255.255.1 dev eth0  scope link

Aside from addresses, same config I had when I was on adsl.

>
> Wow, how does that even work?  Every time I think I know something, I
> get challenged.  I should make that a slogan.
>
> - Greg
>

BTW:

You should be able to avoid whole proxy thing altogether (on your 
router), by doing:

ip add add 1.2.115.157/32 dev eth0
ip ro del table local 192.168.99.5/32 dev eth0
ip route add 1.2.115.157/32 dev eth1

instead of:

ip neigh add proxy 1.2.115.157 dev eth0

The former will still expose the address, but it will be not routable 
inside the router, so will get passed to your internal host. (this 
assumes your kernel is compiled with advanced routing).
