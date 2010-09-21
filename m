From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] ip: fix truesize mismatch in ip fragmentation
Date: Tue, 21 Sep 2010 15:15:34 -0700 (PDT)
Message-ID: <20100921.151534.183050170.davem@davemloft.net>
References: <20100921175014.GA2066@del.dom.local>
	<1285094865.2452.2.camel@edumazet-laptop>
	<20100921192154.GA2115@del.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, nbowler@elliptictech.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net
To: jarkao2@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100921192154.GA2115@del.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 21 Sep 2010 21:21:54 +0200

> On Tue, Sep 21, 2010 at 08:47:45PM +0200, Eric Dumazet wrote:
>> [PATCH v4] ip: fix truesize mismatch in ip fragmentation
>> 
>> Special care should be taken when slow path is hit in ip_fragment() :
>> 
>> When walking through frags, we transfert truesize ownership from skb to
>> frags. Then if we hit a slow_path condition, we must undo this or risk
>> uncharging frags->truesize twice, and in the end, having negative socket
>> sk_wmem_alloc counter, or even freeing socket sooner than expected.
>> 
>> Many thanks to Nick Bowler, who provided a very clean bug report and
>> test program.
>> 
>> Thanks to Jarek for reviewing my first patch and providing a V2
>> 
>> While Nick bisection pointed to commit 2b85a34e911 (net: No more
>> expensive sock_hold()/sock_put() on each tx), underlying bug is older
>> (2.6.12-rc5)
>> 
>> A side effect is to extend work done in commit b2722b1c3a893e
>> (ip_fragment: also adjust skb->truesize for packets not owned by a
>> socket) to ipv6 as well.
>> 
>> Reported-and-bisected-by: Nick Bowler <nbowler@elliptictech.com>
>> Tested-by: Nick Bowler <nbowler@elliptictech.com>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> CC: Jarek Poplawski <jarkao2@gmail.com>
>> CC: Patrick McHardy <kaber@trash.net>
> 
> Looks perfect to me.

Great work everyone!

Applied, thanks.
