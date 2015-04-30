From: "Daney, David" <David.Daney@caviumnetworks.com>
Subject: RE: [PATCH RFC] net/mlx4: Remove improper usage of
 dma_alloc_coherent().
Date: Thu, 30 Apr 2015 00:07:05 +0000
Message-ID: <BN3PR0701MB1719B826CB12B1C6FD9E00989AD60@BN3PR0701MB1719.namprd07.prod.outlook.com>
References: <1428361229-31542-1-git-send-email-ddaney.cavm@gmail.com>
 <55243362.5040207@dev.mellanox.co.il> <552AE4A4.30005@dev.mellanox.co.il>
 <5540E71E.2050200@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Roland Dreier <roland@kernel.org>,
	Sean Hefty <sean.hefty@intel.com>,
	"Hal Rosenstock" <hal.rosenstock@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	"Or Gerlitz" <ogerlitz@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	"Matan Barak" <matanb@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	"Jack Morgenstein" <jackm@dev.mellanox.co.il>,
	Moni Shoua <monis@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.co.il>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Yuval Atias <yuvala@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	David Daney <david.daney@cavium.com>
To: Ido Shamay <idos@dev.mellanox.co.il>,
	David Daney <ddaney.cavm@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5540E71E.2050200@dev.mellanox.co.il>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

First of all, let me apologize for top posting, but it is currently my only option.

I have been away from my office for the last couple of weeks, I was going to re-send on Monday, May 4.  If you would like to do it before then, please go ahead and do that.

Thanks,
David Daney

-----Original Message-----
From: Ido Shamay [mailto:idos@dev.mellanox.co.il] 
Sent: Wednesday, April 29, 2015 7:14 AM
To: David Daney; linux-kernel@vger.kernel.org; netdev@vger.kernel.org; linux-rdma@vger.kernel.org; David S. Miller
Cc: Roland Dreier; Sean Hefty; Hal Rosenstock; Amir Vadai; Or Gerlitz; Yishai Hadas; Matan Barak; Majd Dibbiny; Jack Morgenstein; Moni Shoua; Eugenia Emantayev; Saeed Mahameed; Yuval Atias; Maor Gottlieb; David Daney
Subject: Re: [PATCH RFC] net/mlx4: Remove improper usage of dma_alloc_coherent().


On 4/13/2015 12:33 AM, Ido Shamay wrote:
> On 4/7/2015 10:43 PM, Ido Shamay wrote:
>> On 4/7/2015 2:00 AM, David Daney wrote:
>>> From: David Daney <david.daney@cavium.com>
>>>
>>> The dma_alloc_coherent() function returns a virtual address which 
>>> can be used for coherent access to the underlying memory.  On some 
>>> architectures, like arm64, undefined behavior results if this memory 
>>> is also accessed via virtual mappings that are not coherent. Because 
>>> of their undefined nature, operations like virt_to_page() return 
>>> garbage when passed virtual addresses obtained from 
>>> dma_alloc_coherent().  Any subsequent mappings via vmap() of the 
>>> garbage page values are unusable and result in bad things like bus 
>>> errors (synchronous aborts in ARM64 speak).
>>>
>>> The MLX4 driver contains code that does the equivalent of:
>>>
>>>    vmap(virt_to_page(dma_alloc_coherent))
>>>
>>> This results in an OOPs when the device is opened.
>>>
>>> To fix this...
>>>
>>> Always use result of dma_alloc_coherent() directly.
> Acked-by: Ido Shamay <idos@mellanox.com> Thanks David, this is good 
> for us

Hi David,

Are you resending this patch or you want us to do that?
