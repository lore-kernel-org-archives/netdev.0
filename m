From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 2/2] vhost_net: a kernel-level virtio server
Date: Thu, 13 Aug 2009 09:06:15 +0300
Message-ID: <20090813060615.GC3029@redhat.com>
References: <cover.1249930169.git.mst@redhat.com> <200908121903.22325.arnd@arndb.de> <20090812172141.GA29966@redhat.com> <200908121959.47222.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: virtualization@lists.linux-foundation.org,
	"Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752258AbZHMGHh@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200908121959.47222.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 12, 2009 at 07:59:47PM +0200, Arnd Bergmann wrote:
> The trick is to swap the virtqueues instead. virtio-net is actually
> mostly symmetric in just the same way that the physical wires on a
> twisted pair ethernet are symmetric (I like how that analogy fits).

You need to really squint hard for it to look symmetric.

For example, for RX, virtio allocates an skb, puts a descriptor on a
ring and waits for host to fill it in. Host system can not do the same:
guest does not have access to host memory.

You can do a copy in transport to hide this fact, but it will kill
performance.

-- 
MST
