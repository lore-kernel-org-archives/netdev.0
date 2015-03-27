From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [RFC PATCH 09/11] IB/Verbs: Use management helper has_ipoib()
 and, cap_ipoib() for ipoib-check
Date: Fri, 27 Mar 2015 10:06:16 -0600
Message-ID: <20150327160616.GA28412@obsidianresearch.com>
References: <551579CA.4030901@profitbricks.com>
 <55157BC6.70400@profitbricks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roland Dreier <roland@kernel.org>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	Ira Weiny <ira.weiny@intel.com>, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
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
	Alex Estrin <alex.estrin@int
To: Michael Wang <yun.wang@profitbricks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55157BC6.70400@profitbricks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 27, 2015 at 04:48:22PM +0100, Michael Wang wrote:

> diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
> index 3341754..fcd7558 100644
> +++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
> @@ -1655,7 +1655,7 @@ static void ipoib_add_one(struct ib_device *device)
>      struct ipoib_dev_priv *priv;
>      int s, e, p;
>  
> -    if (!rdma_transport_is_ib(device))
> +    if (!has_ipoib(device))
>          return;

This is a good example of a test that doesn't really make sense, IPoIB
is certainly a port specific attribute.

>      dev_list = kmalloc(sizeof *dev_list, GFP_KERNEL);
> @@ -1673,7 +1673,7 @@ static void ipoib_add_one(struct ib_device *device)
>      }
>  
>      for (p = s; p <= e; ++p) {
> -        if (!rdma_port_ll_is_ib(device, p))
> +        if (!cap_ipoib(device, p))
>              continue;

And down here we test every port.

The routine should just test every port and do nothing if no ports
need IPoIB.

>          dev = ipoib_add_port("ib%d", device, p);
>          if (!IS_ERR(dev)) {
> @@ -1690,7 +1690,7 @@ static void ipoib_remove_one(struct ib_device *device)
>      struct ipoib_dev_priv *priv, *tmp;
>      struct list_head *dev_list;
>  
> -    if (!rdma_transport_is_ib(device))
> +    if (!has_ipoib(device))
>          return;

This test should be made redundant by having ib_get_client_data return
null if ipoib_add_one didn't do anything. Maybe that already happens?

Jason
