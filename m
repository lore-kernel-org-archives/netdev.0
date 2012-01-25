From: Stephen Clark <sclark46@earthlink.net>
Subject: Re: NAT question
Date: Wed, 25 Jan 2012 12:28:39 -0500
Message-ID: <4F203BC7.6090708@earthlink.net>
References: <4F2025BD.20903@earthlink.net> <1327510327.2425.75.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Reply-To: sclark46@earthlink.net
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-masked.atl.sa.earthlink.net ([209.86.89.68]:38695 "EHLO
	elasmtp-masked.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756454Ab2AYR2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2012 12:28:40 -0500
In-Reply-To: <1327510327.2425.75.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/25/2012 11:52 AM, Eric Dumazet wrote:
> Le mercredi 25 janvier 2012 =C3=A0 10:54 -0500, Stephen Clark a =C3=A9=
crit :
>   =20
>> Can iptables do a network to network nat without having to write out=
 a
>> bunch of nat rules.
>> In other words translate  192.168.198.0/24 to 172.16.10.0/24 without
>> having to write out
>> 256 rules.
>>
>> Also can iptables handle 1000 nat rules like above if they have to b=
e
>> written out on
>> a 1.66ghz intel dual core atom with 1gb of mem.
>>
>> I know this isn't appropriate question for devel list but I didn't f=
ind
>> anything googling.
>>
>> Thanks,
>>
>>     =20
> If you are forced to use 256 rules, you could split them into 16 tabl=
es
> of 16 rules and do a hash split.
>
> Since these rules are run only for new connections, it might be OK
> performance wise, depending on rate of connection establishment.
>
> If not, you can try NETMAP :)
>
> # iptables -t nat -A POSTROUTING -s 192.168.198.0/24 -j NETMAP --to 1=
72.16.10.0/24
>
> # iptables -t nat -nvL POSTROUTING
> Chain POSTROUTING (policy ACCEPT 0 packets, 0 bytes)
>   pkts bytes target     prot opt in     out     source               =
destination
>      0     0 NETMAP     all  --  *      *       192.168.198.0/24     =
0.0.0.0/0           172.16.10.0/24
>
>   =20
Thanks Eric,

I assume I need an additional rule like this to translate in the other=20
direction?
iptables -t nat -A POSTROUTING -s 172.16.10.0/24 -j NETMAP --to=20
198.168.198.0/24

iptables -t nat -nvL POSTROUTING
Chain POSTROUTING (policy ACCEPT 0 packets, 0 bytes)
  pkts bytes target     prot opt in     out     source              =20
destination

    15  2535 NETMAP     all  --  *      *       192.168.198.0/24    =20
0.0.0.0/0           172.16.10.0/24
     0     0 NETMAP     all  --  *      *       172.16.10.0/24      =20
0.0.0.0/0           198.168.198.0/24


Also now that I am clued to NETMAP I found this example:
iptables -t mangle -A PREROUTING -s 192.168.1.0/24 -j NETMAP --to=20
10.5.6.0/24

using mangle and PREROUTING - does it matter?

"They that give up essential liberty to obtain temporary safety,
deserve neither liberty nor safety."  (Ben Franklin)

"The course of history shows that as a government grows, liberty
decreases."  (Thomas Jefferson)
