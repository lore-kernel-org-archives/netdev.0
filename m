From: Ben Greear <greearb@candelatech.com>
Subject: Re: How to count tx and rx bytes?
Date: Mon, 15 Dec 2003 14:46:59 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FDE39E3.4000408@candelatech.com>
References: <3FDE13AE.3050402@candelatech.com> <20031215141729.15387fc1.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031215141729.15387fc1.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Mon, 15 Dec 2003 12:03:58 -0800
> Ben Greear <greearb@candelatech.com> wrote:
> 
> 
>>Is there an agreed upon standard for exactly what ethernet drivers
>>should be counting for rx-bytes and tx-bytes?  For example, should the
>>counters include the 4-byte FCS?  Should they include the ethernet header?
> 
> 
> Good question.
> 
> It should be that all drivers use what skb->len ends up with at
> rx/tx time.

A more noticeable problem is what I found in e100:  It was adding
skb->len after doing eth_type_trans, which yanks off the ethernet
header...  I moved it before the eth_type_trans and I am getting
much better numbers.  It does appear that the e1000 is counting the
FCS in transmitted bytes, however, and unless we tell the e100 to
receive the FCS, it will not count those on receive.

> However, it is often faster to just let the hardware keep track
> of these statistics (tg3 is one example of a chip that can do
> this).  And sometimes these mechanisms take the FCS or whatever
> into account and this as you note makes the numbers different.

Maybe the stats-polling code in the driver could do the necessary subtraction
to remove the FCS from the results (ie, subtract (packets-since-last-sample * 4) bytes.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
