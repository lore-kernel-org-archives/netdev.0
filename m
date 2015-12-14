From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] sh_eth: fix kernel oops in skb_put()
Date: Mon, 14 Dec 2015 16:24:47 -0500 (EST)
Message-ID: <20151214.162447.1100345678412142334.davem@davemloft.net>
References: <1498048.4g9dLWgJuk@wasted.cogentembedded.com>
	<20151205.174648.1064779484509050839.davem@davemloft.net>
	<566C3A99.2000103@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yashi@atmark-techno.com,
	linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <566C3A99.2000103@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sat, 12 Dec 2015 18:17:45 +0300

> Hello.
> 
> On 12/6/2015 1:46 AM, David Miller wrote:
> 
>>> In a low memory situation the following kernel oops occurs:
>>>
>>> Unable to handle kernel NULL pointer dereference at virtual address
>>> 00000050
>>> pgd = 8490c000
>>> [00000050] *pgd=4651e831, *pte=00000000, *ppte=00000000
>>> Internal error: Oops: 17 [#1] PREEMPT ARM
>>> Modules linked in:
>>> CPU: 0    Not tainted  (3.4-at16 #9)
>>> PC is at skb_put+0x10/0x98
>>> LR is at sh_eth_poll+0x2c8/0xa10
>>> pc : [<8035f780>]    lr : [<8028bf50>]    psr: 60000113
>>> sp : 84eb1a90  ip : 84eb1ac8  fp : 84eb1ac4
>>> r10: 0000003f  r9 : 000005ea  r8 : 00000000
>>> r7 : 00000000  r6 : 940453b0  r5 : 00030000  r4 : 9381b180
>>> r3 : 00000000  r2 : 00000000  r1 : 000005ea  r0 : 00000000
>>> Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
>>> Control: 10c53c7d  Table: 4248c059  DAC: 00000015
>>> Process klogd (pid: 2046, stack limit = 0x84eb02e8)
>>> [...]
>>>
>>> This is because netdev_alloc_skb() fails and 'mdp->rx_skbuff[entry]'
>>> is left
>>> NULL but sh_eth_rx() later uses it without checking.  Add such
>>> check...
>>>
>>> Reported-by: Yasushi SHOJI <yashi@atmark-techno.com>
>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
>> Applied.
> 
>    Could you also queue this for the stable kernels?

Done.
