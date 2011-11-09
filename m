From: Daniil Stolnikov <danila.st@mail.ru>
Subject: Re: Add IPSec IP Range in Linux kernel
Date: Wed, 9 Nov 2011 15:25:58 +0800
Message-ID: <1674049620.20111109152558@mail.ru>
References: <552673196.20111109103207@mail.ru> <20111109032729.GA11312@gondor.apana.org.au>
Reply-To: Daniil Stolnikov <danila.st@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1251
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	<linux-crypto@vger.kernel.org>,
	<linux-security-module@vger.kernel.org>, <davem@davemloft.net>,
	<adobriyan@gmail.com>, <peter.p.waskiewicz.jr@intel.com>,
	<davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20111109032729.GA11312@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Simple, you break a range policy into parts that can be expressed
> as network/mask and install multiple policies.  The actual policies
> in the kernel just has to have the same effect as the one you
> negotiated with the other side, it does not have to look the same.

> This is also why you can do the same thing with masks + netfilter.

> Cheers,


Please describe in detail, including the schema and sample configuration files!

The fact that I have already tried some options and I did not. Here is a link to a Russian-language correspondence on my problem: http://www.opennet.ru/openforum/vsluhforumID10/4941.html.

Once again, draw a diagram of which should be implemented:

                 (server)                                                        (client 1)
                 _______                                                          _______
                 |      |                                                        |      |---192.168.7.1
                 |      |                                                        |      |---192.168.7.2
192.168.1.0/24---|      |192.168.5.1/24----------------------------192.168.5.2/24|      |---192.168.7.3
                 |      |                       |                                |      |---192.168.7.4
                 |______|                       |                                |______|---192.168.7.5      
                                                |
                                                |                                 (client 2)
                                                |                                _______
                                                |                                |      |---192.168.7.6
                                                |                                |      |---192.168.7.7
                                                -------------------192.168.5.3/24|      |---192.168.7.8
                                                |                                |      |---192.168.7.9
                                                |                                |______|---192.168.7.10
                                                |
                                                |                                 (client 3)
                                                |                                _______
                                                |                                |      |---192.168.7.11
                                                |                                |      |---192.168.7.12
                                                -------------------192.168.5.4/24|      |---192.168.7.13
                                                                                 |      |---192.168.7.14
                                                                                 |______|---192.168.7.15


Tried to do the following:

1) network to host. The connection of course been established, but not all traffic be encrypted.
2) host to host. similarly to 1.
3) network to IP range. I tried different configurations, but the connection did not succeed.

So I came to the conclusion that when we point to the IP range zywall IPSec we actually prescribe what kind of traffic will be encrypted. The rest will be routed but no encryption. Correct if I'm wrong.
If you are not working hard to lay out the configuration files!
