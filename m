From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can-next 2017-02-06,pull-request: can-next
 2017-02-06,Re: pull-request: can-next 2017-02-06,pull-request: can-next
 2017-02-06
Date: Mon, 06 Feb 2017 11:59:10 -0500 (EST)
Message-ID: <20170206.115910.1398846154082627685.davem@davemloft.net>
References: <2b600a5b-f928-fe73-5b30-8b2fc1398068@pengutronix.de>
        <20170206.111259.2261971436931731059.davem@davemloft.net>
        <809cdb71-a29c-f952-0cab-ff643b4906f0@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel@pengutronix.de,
        linux-can@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <809cdb71-a29c-f952-0cab-ff643b4906f0@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Mon, 6 Feb 2017 17:43:43 +0100

> On 02/06/2017 05:12 PM, David Miller wrote:
>> From: Marc Kleine-Budde <mkl@pengutronix.de>
>> Date: Mon, 6 Feb 2017 15:50:48 +0100
>> 
>>> this is a pull request of 16 patches for net-next/master.
>>>
>>> The first two patches by David Jander and me add the rx-offload
>>> framework for CAN devices to the kernel. The remaining 14 patches
>>> convert the flexcan driver to make use of it.
>> 
>> Pulled, but I wonder if your comparisons does the right thing when the
>> counters overflow.
>> 
>> I think you need to do the same thing we do for TCP sequence number
>> comparisons and code it like:
>> 
>> static inline bool before(__u32 seq1, __u32 seq2)
>> {
>>         return (__s32)(seq1-seq2) < 0;
>> }
> 
> Yes, I think it's basically the same as the TCP sequence number code,
> but obviously less readable.
> 
>> static int can_rx_offload_compare(struct sk_buff *a, struct sk_buff *b)
>> {
>> 	const struct can_rx_offload_cb *cb_a, *cb_b;
>> 
>> 	cb_a = can_rx_offload_get_cb(a);
>> 	cb_b = can_rx_offload_get_cb(b);
>> 
>> 	/* Substract two u32 and return result as int, to keep
>> 	 * difference steady around the u32 overflow.
>> 	 */
>> 	return cb_b->timestamp - cb_a->timestamp;
>> }
> 
> This does the "(__s32)(seq1-seq2)"
 ...
> 
> And here the "return ... < 0;"

Sure but what about these "can_rx_offload_le()" comparisons?
