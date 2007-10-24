From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH RESEND] ip_gre: sendto/recvfrom NBMA address
Date: Wed, 24 Oct 2007 08:54:42 +0300
Message-ID: <471EDE22.4090408@iki.fi>
References: <471E05BD.7040407@iki.fi> <471E0638.9040405@trash.net> <471E19E5.5040509@iki.fi> <20071023202036.GA12066@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw03.mail.saunalahti.fi ([195.197.172.111]:54374 "EHLO
	gw03.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753546AbXJXFyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 01:54:50 -0400
In-Reply-To: <20071023202036.GA12066@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Alexey Kuznetsov wrote:
>> The only dubious case is when next hop is set using routing tables.
>> But code in ipgre_tunnel_xmit() is ready to accept this situation,
>> it checks for zero destination address and fixes it when it is able to.
> 
> Nevertheless, it does not work.
> 
> Another thoughts?

Could you explain this a little more?

I was able to set a nbma gre tunnel, add routes to it and it worked
perfectly ok.

Link-level next hop worked:
ip route add <route> via <link-level-address> dev <tunnel-dev> onlink

Also normal route with static neighbor worked:
ip neigh add <router-tunnel-ip> lladdr <link-level-address> nud permanent dev <tunnel-dev>
ip route add <route> via <router-tunnel-ip>

In both cases packets were routed as expected to hosts accessible using
the added route. And sendto() sent a packet correctly with destination
link-level-address set. Did I miss/misunderstand something?

Cheers,
  Timo
