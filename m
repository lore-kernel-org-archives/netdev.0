From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 25 Sep 2015 10:50:34 +1000
Message-ID: <20150925105034.473739fd@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Benc <jbenc@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/ipv4/arp.c

between commit:

  63d008a4e9ee ("ipv4: send arp replies to the correct tunnel")

from the net tree and commit:

  0c4b51f0054c ("netfilter: Pass net into okfn")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/ipv4/arp.c
index f03db8b7abee,61ff5ea31283..000000000000
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@@ -651,8 -654,6 +657,7 @@@ static int arp_process(struct net *net
  	u16 dev_type = dev->type;
  	int addr_type;
  	struct neighbour *n;
- 	struct net *net = dev_net(dev);
 +	struct dst_entry *reply_dst = NULL;
  	bool is_garp = false;
  
  	/* arp_rcv below verifies the ARP header and verifies the device
