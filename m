From: David Rientjes <rientjes@google.com>
Subject: Re: linux-next: build failure after merge of the final tree (net-next
 tree related)
Date: Tue, 23 Apr 2013 16:44:33 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1304231639490.6938@chino.kir.corp.google.com>
References: <20130423174618.59095bd1cf999c61332d4805@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20130423174618.59095bd1cf999c61332d4805@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 23 Apr 2013, Stephen Rothwell wrote:

> Hi all,
> 
> After merging the final tree, today's linux-next build (powerpc
> allyesconfig) failed like this:
> 
> net/netlink/af_netlink.c: In function 'netlink_frame_flush_dcache':
> net/netlink/af_netlink.c:384:40: error: 'NL_MMAP_MSG_HDRLEN' undeclared (first use in this function)
> 
> Caused by commit 9652e931e73b ("netlink: add mmap'ed netlink helper
> functions").  This needed to be build tested on an architecture that has
> ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE set to 1 (like Sparc :-)).
> 

Hijacking this thread since I didn't see the causing patch to be posted to 
lkml.  From linux-next:

net/netlink/af_netlink.c: In function 'netlink_queue_mmaped_skb':
net/netlink/af_netlink.c:663:14: error: incompatible types when assigning to type '__u32' from type 'kuid_t'
net/netlink/af_netlink.c:664:14: error: incompatible types when assigning to type '__u32' from type 'kgid_t'
net/netlink/af_netlink.c: In function 'netlink_ring_set_copied':
net/netlink/af_netlink.c:693:14: error: incompatible types when assigning to type '__u32' from type 'kuid_t'
net/netlink/af_netlink.c:694:14: error: incompatible types when assigning to type '__u32' from type 'kgid_t'

for a config with CONFIG_UIDGID_STRICT_TYPE_CHECKS enabled.

Looks like it's coming from f9c2288837ba ("netlink: implement memory 
mapped recvmsg()").  Patrick?
