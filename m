From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.17-rc1 oops during network interface configuration
Date: Wed, 10 Sep 2014 07:24:32 -0700
Message-ID: <1410359072.7106.27.camel@edumazet-glaptop2.roam.corp.google.com>
References: <53F1EF18.7010909@acm.org> <53F47917.8080003@mellanox.com>
	 <F580F466-28A5-4BDD-A338-D5C065A760C1@oracle.com>
	 <541000F1.5000805@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML Kernel <linux-kernel@vger.kernel.org>,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Bart Van Assche <bvanassche@acm.org>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Roland Dreier <roland@kernel.org>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <541000F1.5000805@mellanox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-09-10 at 10:42 +0300, Or Gerlitz wrote:

> Hi Chuck, thanks for bisecting this out. Indeed, as of this kernel 3.2 
> commit 936d7de "IPoIB: Stop lying about hard_header_len and use skb->cb 
> to stash LL addresses" we are using the skb->cb field to enable proper 
> work under GRO and avoid another historical quirk we had there... so I 
> think we can definetly consider commit e0f31d849 to introduce a severe 
> regression... Govindarajulu, Dave - what's your thinking here? any quick 
> idea on how to fix?

I mentioned the IB stuff when patch was posted, and David replied :

"I think this is fine, IPOIB's control block will need still just 44
bytes after these changes, so there will still be 4 bytes to spare."

http://patchwork.ozlabs.org/patch/357584/

My suggestion was to reduce sch_choke usage and not store the whole
flow_keys.
