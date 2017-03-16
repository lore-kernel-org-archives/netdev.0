From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: Re: [PATCH v2 net-next 4/5] sunvnet: count multicast packets
Date: Wed, 15 Mar 2017 17:17:44 -0700
Message-ID: <4ee0ac85-62a3-2cb2-0d5d-d17e4334bde8@oracle.com>
References: <1489512283-422140-1-git-send-email-shannon.nelson@oracle.com>
 <1489512283-422140-5-git-send-email-shannon.nelson@oracle.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFFB12CF@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFFB12CF@AcuExch.aculab.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/15/2017 1:50 AM, David Laight wrote:
> From: Shannon Nelson
>> Sent: 14 March 2017 17:25
> ...
>> +	if (unlikely(is_multicast_ether_addr(eth_hdr(skb)->h_dest)))
>> +		dev->stats.multicast++;
>
> I'd guess that:
> 	dev->stats.multicast += is_multicast_ether_addr(eth_hdr(skb)->h_dest);
> generates faster code.
> Especially if is_multicast_ether_addr(x) is (*x >> 7).
>
> 	David

Hi David, thanks for the comment.  My local instruction level 
performance guru is on vacation this week so I can't do a quick check 
with him today on this.  However, I"m not too worried here since the 
inline code for is_multicast_ether_addr() is simply

	return 0x01 & addr[0];

and objdump tells me that on sparc it compiles down to a simple single 
byte load and compare:

     325c:	c2 08 80 03 	ldub  [ %g2 + %g3 ], %g1
     3260:	80 88 60 01 	btst  1, %g1
     3264:	32 60 00 b3 	bne,a,pn   %xcc, 3530 <vnet_rx_one+0x430>
     3268:	c2 5c 61 68 	ldx  [ %l1 + 0x168 ], %g1
		dev->stats.multicast++;

I don't think this driver will ever be used on anything bug sparc, so 
I'm not worried about how x86 might compile this.

sln

