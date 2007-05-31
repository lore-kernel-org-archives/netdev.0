From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Thu, 31 May 2007 07:13:14 +0200
Message-ID: <465E596A.3010400@hartkopp.net>
References: <20070530131123.10843.0@janus.isnogud.escape.de> <20070530131204.10843.5@janus.isnogud.escape.de> <465DB0B6.109@trash.net> <465DC4CD.9080801@hartkopp.net> <465DCD90.9070103@trash.net> <465DD506.4000503@hartkopp.net> <465DD755.4070702@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs@isnogud.escape.de>,
	David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:26101 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756447AbXEaFNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2007 01:13:32 -0400
In-Reply-To: <465DD755.4070702@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Oliver Hartkopp wrote:
>   
>> Btw. it's really worth to look at it again. I just had the idea to
>> access the loopback flag via skb->sk->opt->loopback (argpfl!) on the TX
>> path and skb->sk on the RX path. This would avoid skb->sk to be set to
>> NULL but need to have this loopback flag to be implemented in each CAN
>> socket opt.
>>     
>
>
> Yes, thats what I wanted to suggest. You should even be able
> to use skb->sk->opt->loopback on the receive path before you
> queue the packet to the socket.
>   

Using skb->sk->opt->loopback on the receive path is not possible as you
also have to deal with 'real' data received from a 'real' netdevice,
where no sk is bound to the skb. The idea is to check on the rx path ,
if sbk->sk is 'me' and then trash the packet according to my sockopt
settings.

Regards,
Oliver

