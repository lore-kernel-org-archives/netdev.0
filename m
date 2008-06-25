From: Naohiro Ooiwa <nooiwa@miraclelinux.com>
Subject: Re: (usagi-users 04056) Re: ping6 is sent out from wrong interface
Date: Wed, 25 Jun 2008 19:18:38 +0900
Message-ID: <48621B7E.5090600@miraclelinux.com>
References: <4861ED72.6080100@miraclelinux.com> <69A5E767EC979846826F566C7932A3F207233B5F@exchange03.iabg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: usagi-users@ml.linux-ipv6.org,
	=?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2k=?=
	 =?ISO-2022-JP?B?IC8gGyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org,
	usagi-users@linux-ipv6.org
To: Fey Marcus <Fey@iabg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:26741 "EHLO
	mail.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754649AbYFYKSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 06:18:40 -0400
In-Reply-To: <69A5E767EC979846826F566C7932A3F207233B5F@exchange03.iabg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Marcus

Thank you for your quick reply.

> It's due to routing.

For the reason of selecting 'eth0', I agree.
But, I think the device is specified before
looking up the routing table in this case.

> ...with eth0 being preferred over eth1 for multicast packets.
> You could add a dedicated route for ff02::/16 to make the kernel output the packet via eth1.

This works when using only "eth1" for multicasts.
When multiple I/Fs are connected to separate networks,
this scheme requires changing the route every time
a user need to send ping to different network.

I think kernel can solve this problem better.


Regards,
Naohiro Ooiwa


Fey Marcus さんは書きました:
> Hi Naohiro,
> 
>> I'm not convinced yet.
>> I don't think it's correct that kernel or ping6 arbitrarily 
>> decides outgoing interface.
>>
>> Is this really an expected behaviour?
>> Could you explain to me the reason of it, too?
>>
>> I think the behavior should be similar to IPv4.
> 
> It's due to routing.
> 
> Your routing table shows this:
> ---
>     # route -A inet6
>     Kernel IPv6 routing table
>     Destination            Next Hop Flags Metric Ref    Use Iface
>     2001:2c0:418:1::/64    *        U     256    0        0 eth0
>     2001:2c0:418:2::/64    *        U     256    0        0 eth1
>     fe80::/64              *        U     256    0        0 eth0
>     fe80::/64              *        U     256    0        0 eth1
>     ::::::
>     2001:2c0:418:1::1/128  *        U     0      8        1 lo
>     2001:2c0:418:2::2/128  *        U     0      5        1 lo
>     ::::::
>     ff00::/8               *        U     256    0        0 eth0
>     ff00::/8               *        U     256    0        0 eth1
>     #
> ---
> 
> ...with eth0 being preferred over eth1 for multicast packets.
> 
> You could add a dedicated route for ff02::/16 to make the kernel output the packet via eth1.
> 
> Bye,
> 
> Marcus
> -----------------------------------------
> IABG mbH
> Sitz der Gesellschaft: Ottobrunn, Registergericht: Amtsgericht Muenchen, HRB 5499
> Geschaeftsfuehrung: Prof. Dr.-Ing. Rudolf F. Schwarz
> Vorsitzender des Aufsichtsrats: General a. D. Wolfgang Altenburg
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

