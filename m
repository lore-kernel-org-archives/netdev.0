From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: take 2-2  WAS(Re: PATCH: IPSEC xfrm events
Date: Tue, 05 Apr 2005 16:35:47 +0900
Message-ID: <42523FD3.8010400@linux-ipv6.org>
References: <1112406164.1088.54.camel@jzny.localdomain>	 <20050402014619.GB24861@gondor.apana.org.au>	 <1112469601.1088.173.camel@jzny.localdomain>	 <1112538718.1096.394.camel@jzny.localdomain>	 <20050404005805.GA16543@gondor.apana.org.au>	 <1112614706.1096.439.camel@jzny.localdomain>	 <20050404121641.GA12103@gondor.apana.org.au>	 <1112619096.1088.473.camel@jzny.localdomain>	 <20050404130224.GA12546@gondor.apana.org.au>	 <1112620614.1088.489.camel@jzny.localdomain>	 <20050404213149.GA15222@gondor.apana.org.au>	 <1112653217.1088.2.camel@jzny.localdomain>	 <20050404152506.15e1404b.davem@davemloft.net> <1112654575.1089.17.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, herbert@gondor.apana.org.au,
        kaber@trash.net, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1112654575.1089.17.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello Jamal,

jamal wrote:
> On Mon, 2005-04-04 at 18:25, David S. Miller wrote:
> 
> 
>>If you only take write_lock() from process context, only the write_lock()'s
>>need BH disabling.  read_lock() takers can then nest arbitrarily, BH or not.
> 
> 
> Ok, never mind - Ive made the change. 
> As soon as Masahide tests i will post the final patch.

I've tested normal cases below with the latest patch and it works fine.
I think you can go ahead.

tested cases:
  o netlink (using iproute2 "ip xfrm monitor" to confirm it)
    - add/del/flush/expire for SA/SP
    - acquire,allocspi,update for SA
    - update for SP
  o pfkey
    - running racoon
  o both sockets
    - running racoon with using "ip xfrm monitor".

Regards,

-- 
Masahide NAKAMURA
