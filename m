From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH 00/13] mvneta Buffer Management and enhancements
Date: Tue, 8 Dec 2015 11:56:28 +0100
Message-ID: <CAPv3WKeTqWXvABPHovH6dqUz_qs88Wy7Q6cbOHsujt4CM0=32g@mail.gmail.com>
References: <CAPv3WKc4zSmjtw_FeePCVCaq_aUubbCw_ggtxgxs0-7LwL7fHQ@mail.gmail.com>
	<20151129.210210.1777978635596463961.davem@davemloft.net>
	<CAPv3WKcHnJHCvg63Vs79RboNOuESU8jCLouKPRW4NdptAd_hag@mail.gmail.com>
	<20151130.112500.293198684175670933.davem@redhat.com>
	<CAPv3WKcKm3X3Lys2HwYZXaZxPaajenF7av1wJKXqKxxwibXW4A@mail.gmail.com>
	<5661F449.5020205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Jason Cooper <jason@lakedaemon.net>,
	Yair Mahalalel <myair@marvell.com>,
	Grzegorz Jaszczyk <jaz@semihalf.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Evan Wang <xswang@marvell.com>, nadavh@marvell.com,
	Lior Amsalem <alior@marvell.com>,
	Tomasz Nowicki <tn@semihalf.com>,
	=?UTF-8?Q?Gregory_Cl=C3=A9ment?=
	<gregory.clement@free-electrons.com>, nitroshift@yahoo.com,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: David Miller <davem@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5661F449.5020205@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

2015-12-04 21:15 GMT+01:00 Florian Fainelli <f.fainelli@gmail.com>:
> (no top posting please)
>
> On 02/12/15 00:26, Marcin Wojtas wrote:
>> Hi Florian,
>>
>> Can you please describe in more details, what would you expect from
>> such special abstraction layer regarding buffer managers? I'd like to
>> understand more of your expectations and evaluate possible work.
>
> Well, something along these lines:
>
> - have the ability to register a particular pool (location + number of
> buffers) in a way that is relatively device agnostic (initialization
> would of course be device specific)
>
> - provide a set of buffer management APIs like those you proposed below,
> and have some generic code that leverages what
> drivers/net/ethernet/sun/niu.c does for instance
>
> - introduce a netdev_alloc_skb_from_pool() or something like that which
> would limit the amount of code to change in your network driver to
> benefit from that feature so based
>
> I am sure David would be able to suggest more detailed API.
>

As we're getting closer to what a generic BM part, could you please
share your thoughts on the possible API?


>>>
>>>> What kind of abstraction and helpers do you mean? Some kind of API
>>>> (e.g. bm_alloc_buffer, bm_initialize_ring bm_put_buffer,
>>>> bm_get_buffer), which would be used by platform drivers (and specific
>>>> aplications if one wants to develop on top of the kernel)?
>>>>
>>>> In general, what is your top-view of such solution and its cooperation
>>>> with the drivers?
>>>
>>> The tricky parts involved have to do with allocating pages for the
>>> buffer pools and minimizing the number of atomic refcounting
>>> operations on those pages for for the puts and gets, particularly
>>> around buffer replenish runs.
>>>
>>> For example, if you're allocating a page for a buffer pool the device
>>> will chop into N (for any N < PAGE_SIZE) byte pieces, you can
>>> eliminate many atomic operations.
>

Do you think you can point to anything similar that could be a sort of
reference for such solution?

Best regards,
Marcin
