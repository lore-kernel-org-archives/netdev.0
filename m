From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH] xen-netfront: Fix handling packets on compound pages
 with skb_segment
Date: Fri, 1 Aug 2014 12:02:46 +0100
Message-ID: <20140801110246.GB17947@zion.uk.xensource.com>
References: <1406726730-17994-1-git-send-email-zoltan.kiss@citrix.com>
 <20140731.132520.1889577477638334755.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <zoltan.kiss@citrix.com>, <konrad.wilk@oracle.com>,
	<boris.ostrovsky@oracle.com>, <david.vrabel@citrix.com>,
	<wei.liu2@citrix.com>, <Ian.Campbell@citrix.com>,
	<paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <xen-devel@lists.xenproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140731.132520.1889577477638334755.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 31, 2014 at 01:25:20PM -0700, David Miller wrote:
> From: Zoltan Kiss <zoltan.kiss@citrix.com>
> Date: Wed, 30 Jul 2014 14:25:30 +0100
[...]
> Secondly, for something like UDP you can't just split the packet up
> like this, or for any other datagram protocol for that matter.
> 
> I know you're in a difficult situation, but I just can't see this
> being an acceptable approach to solving the problem right now.
> 
> Where does the MAX_SKB_FRAGS + 1 limit really come from, the size of
> the TX queue?
> 

It stems from the implicit transimit protocol since inception of
netfront / netback. Sigh.

> If you were to have a 64-slot TX queue, you ought to be able to handle
> this theoretical 51 slot SKB.
> 

There's two problems:
1. IIRC a single page ring has 256 slots, allowing 64 slots packet
   yields 4 in-flight packets in worst case.
2. Older netback could not handle this large number of slots and it's
   likely to deem the frontend malicious.

For #1, we don't actually care that much if guest screws itself by
generating 64 slot packets. #2 is more concerning.

Wei.

> And I don't think it's so theoretical, a carefully crafted sequence of
> sendfile() calls during a TCP_CORK sequence should be able to do it.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
