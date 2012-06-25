From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next RFC V3 PATCH 4/6] tuntap: multiqueue support
Date: Mon, 25 Jun 2012 11:41:51 +0300
Message-ID: <20120625084151.GA18987@redhat.com>
References: <20120625060830.6765.27584.stgit@amd-6168-8-1.englab.nay.redhat.com>
 <20120625061018.6765.76633.stgit@amd-6168-8-1.englab.nay.redhat.com>
 <20120625082553.GC18229@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: habanero@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, krkumar2@in.ibm.com,
	tahm@linux.vnet.ibm.com, akong@redhat.com, davem@davemloft.net,
	shemminger@vyatta.com, mashirle@us.ibm.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120625082553.GC18229@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 25, 2012 at 11:25:53AM +0300, Michael S. Tsirkin wrote:
> On Mon, Jun 25, 2012 at 02:10:18PM +0800, Jason Wang wrote:
> > This patch adds multiqueue support for tap device. This is done by abstracting
> > each queue as a file/socket and allowing multiple sockets to be attached to the
> > tuntap device (an array of tun_file were stored in the tun_struct). Userspace
> > could write and read from those files to do the parallel packet
> > sending/receiving.
> > 
> > Unlike the previous single queue implementation, the socket and device were
> > loosely coupled, each of them were allowed to go away first. In order to let the
> > tx path lockless, netif_tx_loch_bh() is replaced by RCU/NETIF_F_LLTX to
> > synchronize between data path and system call.
> 
> Don't use LLTX/RCU. It's not worth it.

Or maybe we should use LLTX. Need to think about it.
But if yes I'd like a separate patch moving tun to LLTX
and move it always to LLTX. Don't play with LLTX at runtime.

-- 
MST
