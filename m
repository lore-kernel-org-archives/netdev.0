From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: thunderx: Set recevie buffer page usage count
 in bulk
Date: Thu, 10 Mar 2016 12:44:50 -0500 (EST)
Message-ID: <20160310.124450.278421705870462421.davem@davemloft.net>
References: <20160307.120410.1851177945150642006.davem@davemloft.net>
	<CA+sq2CcyOV3FbpUvSkX4ZhjC+fJuHk9cUpjdiJtkFNaEXOWu6Q@mail.gmail.com>
	<CA+sq2Cc44v_ggy=QLOX_FGt6uTv3Qo1KmqCeZ8=3G1COuWxAHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, sgoutham@cavium.com,
	robert.richter@caviumnetworks.com
To: sunil.kovvuri@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+sq2Cc44v_ggy=QLOX_FGt6uTv3Qo1KmqCeZ8=3G1COuWxAHw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Date: Thu, 10 Mar 2016 16:13:28 +0530

> Hi David,
> 
> 
>>> So if you know ahead of time how the page will be split up, just
>>> calculate that when you get the page and increment the page count
>>> appropriately.
>>>
>>> That's what we do in the NIU driver.
>>
>> Thanks for the suggestion, will check and get back.
>>
> 
> I looked at the NIU driver and in fn() niu_rbr_refill()
> static void niu_rbr_refill(struct niu *np, struct rx_ring_info *rp, gfp_t mask)
> {
>         int index = rp->rbr_index;
> 
>         rp->rbr_pending++;
>         if ((rp->rbr_pending % rp->rbr_blocks_per_page) == 0) {
> 
> Here it's been checked whether rbr_pending is a exact multiple of page
> split count.
> And hence updating page count based on fixed calculation is right.
> 
> On my platform driver receives a interrupt when free buffer count
> falls below a threshold
> and by the time SW reads count of buffers to be refilled it can be any
> number i.e
> may or may not be a exact multiple of page split count.

So calculate the modulus on the page split count and optimize the
increment ahead of time when possible, and for the sub page split
pieces do it one at a time.

I don't understand what the problem is.
