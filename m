From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] sctp: check dst validity after IPsec operations
Date: Fri, 07 Sep 2012 15:47:15 +0200
Message-ID: <5049FAE3.2050403@6wind.com>
References: <1346953229-3825-1-git-send-email-nicolas.dichtel@6wind.com> <20120906.141019.129727465932440024.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vyasevich@gmail.com, sri@us.ibm.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:36685 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760624Ab2IGNrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 09:47:20 -0400
Received: by eekc1 with SMTP id c1so1186467eek.19
        for <netdev@vger.kernel.org>; Fri, 07 Sep 2012 06:47:18 -0700 (PDT)
In-Reply-To: <20120906.141019.129727465932440024.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/09/2012 20:10, David Miller a =E9crit :
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Thu,  6 Sep 2012 13:40:29 -0400
>
>> dst stored in struct sctp_transport needs to be recalculated when ip=
sec policy
>> are updated. We use flow_cache_genid for that.
>>
>> For example, if a SCTP connection is established and then an IPsec p=
olicy is
>> set, the old SCTP flow will not be updated and thus will not use the=
 new
>> IPsec policy.
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
> I don't like that SCTP need to perform special DST validation.
Ipv6 do the same:

inet6_csk_xmit()->inet6_csk_route_socket()->__inet6_csk_dst_check()
-> compare flow_cache_genid and rt6i_flow_cache_genid.

>
> The normal DST validation mechanism already in place should be
> sufficient.
I don't find why TCP recalculate the route, but it's not immediate, we =
should=20
wait a little.

>
> Otherwise this problem must exist in other protocols too, and
> fixing a tree wide issue privately inside of one protocol is
> not acceptable.
I will propose another patch.


Regards,
Nicolas
