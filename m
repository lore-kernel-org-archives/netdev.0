From: Yun Wang <yun.wang@profitbricks.com>
Subject: Re: [RFC PATCH 07/11] IB/Verbs: Use management helper has_mcast()
 and, cap_mcast() for mcast-check
Date: Fri, 27 Mar 2015 19:09:27 +0100
Message-ID: <CAJuTgQUKMYOE7XBxUPG=amYi1zSJ-7FVk92uf4pVbGimtymXMw@mail.gmail.com>
References: <551579CA.4030901@profitbricks.com>
	<55157B71.6040505@profitbricks.com>
	<20150327162820.GC28412@obsidianresearch.com>
	<20150327170508.GB27862@phlsvsds.ph.intel.com>
	<CAJuTgQUSm0pM8pqLiivTrKbhtXkKYZaZbBxYFTog0JatzQm3=g@mail.gmail.com>
	<20150327174941.GC28901@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "ira.weiny" <ira.weiny@intel.com>,
	Roland Dreier <roland@kernel.org>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
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
	Matan Barak <m
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150327174941.GC28901@obsidianresearch.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 27, 2015 at 6:49 PM, Jason Gunthorpe
<jgunthorpe@obsidianresearch.com> wrote:
> On Fri, Mar 27, 2015 at 06:31:26PM +0100, Yun Wang wrote:
>
>> Maybe we can temporarily reserve the old logical, and gradually solve
>> these problems?
>
> It is best to make behavioral changes in small patches, yes.
>
> I think it is best to address these sorts of problems before trying to
> tackle the driver interface side - that will avoid complexity.
>
> ie how does a driver set has_ipoib? It isn't even a sensible question
> when it is a per port capability.

I used to imaging it would like:

init_device_mgmt_attributs(device)
{
    for_each_port(device)
        if (port support XX) {
            port.mgmt_attribute |= CAP_XX
             if !(device.mgmt_attribute & HAS_XX)
                 device.mgmt_attribute |= HAS_XX
        }
}

That is incase if a device got one port have some capability, the
device have it too, so has_XX() will check on device level that if it
has any port support XX, and cap_XX() to check on port level.

But if has_XX() is only for optimizing the init/exit path, then it
doesn't make sense to me any more...

Regards,
Michael Wang

>
> Jason
