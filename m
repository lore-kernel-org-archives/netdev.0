From: Michael Wang <yun.wang@profitbricks.com>
Subject: Re: [RFC PATCH 08/11] IB/Verbs: Use management helper has_iwarp()
 for, iwarp-check
Date: Tue, 31 Mar 2015 15:58:52 +0200
Message-ID: <551AA81C.30701@profitbricks.com>
References: <551579CA.4030901@profitbricks.com> <55157B98.1060103@profitbricks.com> <20150327161319.GB28412@obsidianresearch.com> <20150327171631.GC27862@phlsvsds.ph.intel.com> <20150327172912.GA28901@obsidianresearch.com> <55196754.5010600@profitbricks.com> <20150330223528.GB27728@obsidianresearch.com> <551A4F24.6090405@profitbricks.com> <551A82D3.70806@talpey.com> <551A87D3.2070306@profitbricks.com> <551AA78D.4040502@talpey.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "ira.weiny" <ira.weiny@intel.com>,
	Roland Dreier <roland@kernel.org>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@primarydata.com>,
	"David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	PJ Waskiewicz <pj.waskiewicz@solidfire.com>,
	Tatyana Nikolova <Tatyana.E.Nikolova@intel.com>,
	Yan Burman <yanb@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Bart Van Assche <bvanassche@acm.org>,
	Yann Droneaud <ydroneaud@opteya.com>,
	Colin Ian King <colin.king@canonical.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Matan Barak <matanb@mellanox.com>,
	Alex Estrin <alex.estrin@
To: Tom Talpey <tom@talpey.com>,
	Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <551AA78D.4040502@talpey.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/31/2015 03:42 PM, Tom Talpey wrote:

> On 3/31/2015 7:41 AM, Michael Wang wrote:
>> [snip]
> Yes, in fact the iWARP protocol does not preclude multiple read SGEs,
> even though most iWARP implementations have chosen to support just one.
>
> Even for multi-SGE-capable adapters, there is a limit of SGL size, based
> on the adapter's work request format and other factors. So my argument
> is that upper layers can and should query that, not make a blanket
> decision based on protocol type.

Thanks for the explanation  Sounds like some new callback on device level
like query_device() to acquire the right info.

>> I currently only find this one place where infer max-read-sges from
>> transport type, it looks more like a special case to me rather than a generic
>> method we could exposed... and also  not very related with IB management
>> helper concept IMHO.
> It is most certainly not a special case, but you could decide to
> introduce it in many ways. I'm not commenting on that.
>
> My main concern is that you do not introduce a new and clumsy "is iWARP"
> rule as an adapter-specific API requirement to expose the RDMA Read SGE
> behavior. That's what your initial message seemed to imply?

Yeah I planed to just use rdma_transport_iwarp() to replace the check, it's
actually meaningless but just refine, frankly speaking I would prefer some
driver developer to work on that part, at this point I prefer to focus on
introducing the management helpers firstly 

Maybe we could mark it as a TODO temporarily, if later we found more
scenes using similar logical, we can collect them and do some reform 

Regards,
Michael Wang
