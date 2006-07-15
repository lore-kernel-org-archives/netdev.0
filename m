From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] clear skb cb on IP input
Date: Sat, 15 Jul 2006 08:50:58 -0700
Message-ID: <44B90EE2.1080808@osdl.org>
References: <E1G1kCA-000533-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, guichaz@yahoo.fr,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:29129 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750715AbWGOPvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jul 2006 11:51:12 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1G1kCA-000533-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> David Miller <davem@davemloft.net> wrote:
>   
>> Thank goodness this thing is only 3-words in size, this is going to
>> run on every single IPv4 packet received by the system. :-/
>>     
>
> At least this lets us get rid of a few other memsets :)
>
> [IPV4]: Get rid of redundant IPCB->opts initialisation
>
> Now that we always zero the IPCB->opts in ip_rcv, it is no longer
> necessary to do so before calling netif_rx for tunneled packets.
>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
> Cheers
>   

Since skb->cb is aligned, we could optimize the initialization
slightly by just using:
    *(unsigned long *)skb->cb = 0;

