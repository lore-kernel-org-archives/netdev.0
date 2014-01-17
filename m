From: saeed bishara <saeed.bishara@gmail.com>
Subject: Re: [PATCH v3 1/4] net_dma: simple removal
Date: Fri, 17 Jan 2014 22:16:06 +0200
Message-ID: <CAMAG_efOD03wLtetfNAfymsCs6kVEqoJx6e7qY2txBBMDgbmfQ@mail.gmail.com>
References: <20140114004509.27138.50345.stgit@viggo.jf.intel.com>
 <20140114004622.27138.54103.stgit@viggo.jf.intel.com> <CAMAG_eduH4M2OPVh-R4Q6KG1DDcinEDzC-fQyXj1mLdZG=49hw@mail.gmail.com>
 <CAPcyv4hzNT15R41zSOM98f-0aQ60HBZoD_DAvf6VED7iXoCZ8w@mail.gmail.com> <CAPcyv4ixMVV5-9NPR_Nx-hgwAGBS8uh1DQabjimCaNfYt30kiA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dmaengine@vger.kernel.org" <dmaengine@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Dave Jiang <dave.jiang@intel.com>,
	Vinod Koul <vinod.koul@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Whipple <whipple@securedatainnovations.ch>,
	lkml <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Dan Williams <dan.j.williams@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPcyv4ixMVV5-9NPR_Nx-hgwAGBS8uh1DQabjimCaNfYt30kiA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dan,

isn't this issue similar to direct io case?
can you please look at the following article
http://lwn.net/Articles/322795/

regarding performance improvement using NET_DMA, I don't have concrete
numbers, but it should be around 15-20%. my system is i/o coherent.

saeed

On Wed, Jan 15, 2014 at 11:33 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> On Wed, Jan 15, 2014 at 1:31 PM, Dan Williams <dan.j.williams@intel.com> wrote:
>> On Wed, Jan 15, 2014 at 1:20 PM, saeed bishara <saeed.bishara@gmail.com> wrote:
>>> Hi Dan,
>>>
>>> I'm using net_dma on my system and I achieve meaningful performance
>>> boost when running Iperf receive.
>>>
>>> As far as I know the net_dma is used by many embedded systems out
>>> there and might effect their performance.
>>> Can you please elaborate on the exact scenario that cause the memory corruption?
>>>
>>> Is the scenario mentioned here caused by "real life" application or
>>> this is more of theoretical issue found through manual testing, I was
>>> trying to find the thread describing the failing scenario and couldn't
>>> find it, any pointer will be appreciated.
>>
>> Did you see the referenced commit?
>>
>> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=77873803363c
>>
>> This is a real issue in that any app that forks() while receiving data
>> can cause the dma data to be lost.  The problem is that the copy
>> operation falls back to cpu at many locations.  Any one of those
>> instance could touch a mapped page and trigger a copy-on-write event.
>> The dma completes to the wrong location.
>>
>
> Btw, do you have benchmark data showing that NET_DMA is beneficial on
> these platforms?  I would have expected worse performance on platforms
> without i/o coherent caches.
