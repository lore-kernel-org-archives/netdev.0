From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the rdma-leon-test tree with the
 net-next tree
Date: Tue, 8 Nov 2016 13:06:23 +1100
Message-ID: <20161108130623.4b9b4403@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        David Ahern <dsa@cumulusnetworks.com>
To: Leon Romanovsky <leon@kernel.org>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Leon,

Today's linux-next merge of the rdma-leon-test tree got a conflict in:

  drivers/infiniband/core/roce_gid_mgmt.c

between commit:

  453d39329ad0 ("IB/core: Flip to the new dev walk API")

from the net-next tree and commit:

  e4b4d6b5d8c2 ("IB/core: Remove debug prints after allocation failure")

from the rdma-leon-test tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/infiniband/core/roce_gid_mgmt.c
index 3a64a0881882,c86ddcea7675..000000000000
--- a/drivers/infiniband/core/roce_gid_mgmt.c
+++ b/drivers/infiniband/core/roce_gid_mgmt.c
@@@ -437,28 -434,6 +434,26 @@@ static void callback_for_addr_gid_devic
  			  &parsed->gid_attr);
  }
  
 +struct upper_list {
 +	struct list_head list;
 +	struct net_device *upper;
 +};
 +
 +static int netdev_upper_walk(struct net_device *upper, void *data)
 +{
 +	struct upper_list *entry = kmalloc(sizeof(*entry), GFP_ATOMIC);
 +	struct list_head *upper_list = data;
 +
- 	if (!entry) {
- 		pr_info("roce_gid_mgmt: couldn't allocate entry to delete ndev\n");
++	if (!entry)
 +		return 0;
- 	}
 +
 +	list_add_tail(&entry->list, upper_list);
 +	dev_hold(upper);
 +	entry->upper = upper;
 +
 +	return 0;
 +}
 +
  static void handle_netdev_upper(struct ib_device *ib_dev, u8 port,
  				void *cookie,
  				void (*handle_netdev)(struct ib_device *ib_dev,
