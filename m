From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH stable 3.11+] can: use private sk reference to detect
 originating socket
Date: Wed, 29 Jan 2014 21:40:58 +0100
Message-ID: <52E9675A.4070201@hartkopp.net>
References: <52E905C8.1060408@hartkopp.net>		 <1391007745.28432.36.camel@edumazet-glaptop2.roam.corp.google.com>		 <1391009406.28432.38.camel@edumazet-glaptop2.roam.corp.google.com>	 <1391010437.28432.39.camel@edumazet-glaptop2.roam.corp.google.com>	 <52E956E6.7090002@hartkopp.net> <1391025348.28432.63.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andre Naujoks <nautsch2@gmail.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1391025348.28432.63.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 29.01.2014 20:55, Eric Dumazet wrote:

>> 2. The check for sk and the additional skb_orphan() is not needed as the
>> can_skb_set_owner() is invoked only after 'fresh' skb allocation or after
>> clone/skb_orphan() - so we know the skb state very good.
> 
> Yep, but then you added skb_orphan() calls. when skb is not shared.

I did that e.g. in the sources placed in driver/net/can because I assume that
I can not be sure that I always get skbs created by AF_CAN.

E.g. one could also use AF_PACKET to send CAN frames to the CAN interfaces.

Btw. assuming AF_PACKET does it correct too with the destructor I will omit
the skb_orphan() / can_skb_set_owner() sequence in drivers/net/can in the next
attempt.

Tnx
Oliver

> 
> I think you really should have a helper instead of copying this 3 times.
> 

ok

