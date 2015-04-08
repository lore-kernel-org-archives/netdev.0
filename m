From: Tom Talpey <tom@talpey.com>
Subject: Re: [PATCH v2 01/17] IB/Verbs: Implement new callback query_transport()
 for each HW
Date: Wed, 08 Apr 2015 16:55:31 -0400
Message-ID: <552595C3.8040506@talpey.com>
References: <5523CCD5.6030401@profitbricks.com> <5523D098.3020007@profitbricks.com> <1428517786.2980.180.camel@redhat.com> <20150408201015.GB28666@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Wang <yun.wang@profitbricks.com>,
	Roland Dreier <roland@kernel.org>,
	Sean Hefty <sean.hefty@intel.com>, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org, Hal Rosenstock <hal.rosenstock@gmail.com>,
	Tom Tucker <tom@opengridcomputing.com>,
	Steve Wise <swise@opengridcomputing.com>,
	Hoang-Nam Nguyen <hnguyen@de.ibm.com>,
	Christoph Raisch <raisch@de.ibm.com>,
	Mike Marciniszyn <infinipath@intel.com>,
	Eli Cohen <eli@mellanox.com>,
	Faisal Latif <faisal.latif@intel.com>,
	Upinder Malhi <umalhi@cisco.com>,
	Trond Myklebust <trond.myklebust@primarydata.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ira Weiny <ira.weiny@intel.com>,
	PJ Waskiewicz <pj.waskiewicz@solidfire.com>,
	Tatyana Nikolova <Tatyana.E.Nikolova@intel.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgens
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	Doug Ledford <dledford@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150408201015.GB28666@obsidianresearch.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/8/2015 4:10 PM, Jason Gunthorpe wrote:
> On Wed, Apr 08, 2015 at 02:29:46PM -0400, Doug Ledford wrote:
>
>...
>>
>> rdma_port_get_read_sge(dev, port)
>> {
>> 	if (rdma_transport_is_iwarp)
>> 		return 1;
>> 	return dev->port[port]->max_sge;
>> }
>
> Hum, that is nice, but it doesn't quite fit with how the ULP needs to
> work. The max limit when creating a WR is the value passed into the
> qp_cap, not the device maximum limit.

Agreed, and I will again say that not all devices necessarily support
the same max_sge for all WR types. The current one-size-fits-all API
may make the upper layer think so, but it's possibly being lied to.

> To do this properly we need to extend the qp_cap, and that is just too
> big a change. A one bit iWarp quirk is OK for now.

Yes, it would be a large-ish change, and I like Doug's choice of word
"quirk" to capture these as exceptions, until the means for addressing
them is decided.

Overall, I like Doug's proposals, especially from an upper layer
perspective. I might suggest further refining them into categories, 
perhaps "management", primarily of interest to kernel and the
plumbing of connections; and actual "RDMA semantics", of interest
to RDMA consumers.
