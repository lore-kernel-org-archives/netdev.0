From: Ben Greear <greearb@candelatech.com>
Subject: Re: Ethernet bridge performance
Date: Thu, 07 Aug 2003 09:57:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F3284EA.5050406@candelatech.com>
References: <3F3217E7.2080903@allot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Felix Radensky <felix@allot.com>
In-Reply-To: <3F3217E7.2080903@allot.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Felix Radensky wrote:
> Hi,
> 
> I'm evaluating a performance of a dual port ethernet bridge, and the
> results are a bit disappointing. I would appreciate any hints on improving
> the results.

> c01a13ac 7983     12.5065     eth_type_trans
> c01a1590 7629     11.9519     qdisc_restart
> c0197720 7365     11.5383     skb_release_data
> c010c170 5962      9.3403     do_gettimeofday

If that do_gettimeofday is happening in the skb rx code, then
you could gain ~10% by disabling it somehow..as it should not
matter for a bridge.  I bet Robert's skb-recycle patch would
help here too, especially if you allowed the NICs to save up a large
number of skbs so that alloc was less likely to fail.

Btw, I've considered saving, say, 10k skbs on a list in my module,
allocated by GFP_KERNEL at module load time, and using them when
GFP_ATOMIC skb_alloc fails in the IRQ handling portion of the code....

Anyone think that's a good idea? :)

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
