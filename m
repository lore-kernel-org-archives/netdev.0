From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] get_random_bytes returns the same on every boot
Date: Fri, 23 Jul 2004 01:28:59 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41004DBB.5030801@trash.net>
References: <Pine.LNX.4.58.0407222254440.3652@pingvin.fazekas.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Balint Marton <cus@fazekas.hu>
In-Reply-To: <Pine.LNX.4.58.0407222254440.3652@pingvin.fazekas.hu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Balint Marton wrote:
> Hi, 
> 
> At boot time, get_random_bytes always returns the same random data, as if
> there were a constant random seed. For example, if I use the kernel level
> ip autoconfiguration with dhcp, the kernel will create a dhcp request
> packet with always the same transaction ID. (If you have more than one
> computers, and they are booting at the same time, then this is a big
> problem)
> 
> That happens, because only the primary entropy pool is initialized with
> the system time, in function rand_initialize. The secondary pool is only
> cleared. In this early stage of booting, there is usually no user
> interaction, or usable disk interrupts, so the kernel can't add any real
> random bytes to the primary pool. And altough the system time is in the
> primary pool, the kernel does not consider it real random data, so you
> can't read from the primary pool, before at least a part of it will be
> filled with some real randomness (interrupt timing).
> Therefore all random data will come from the secondary pool, and the
> kernel cannot reseed the secondary pool, because there is no real 
> randomness in the primary one.
> 
> The solution is simple: Initialize not just the primary, but also the 
> secondary pool with the system time. My patch worked for me with 
> 2.6.8-rc2, but it was not tested too long. 

Many network hashes use get_random_bytes() to initialize a secret
value to avoid attacks on the hash function when first used.
I assume if DHCP can get bad random, they can too. Is this patch
enough to prevent get_random_bytes() from returning predictable
data at boot time ?

Regards
Patrick
