From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: vhost: build failure
Date: Wed, 16 Sep 2015 11:36:45 +0300
Message-ID: <20150916112119-mutt-send-email-mst@redhat.com>
References: <20150916082008.GA28512@sudip-pc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20150916082008.GA28512@sudip-pc>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 16, 2015 at 01:50:08PM +0530, Sudip Mukherjee wrote:
> Hi,
> While crosscompiling the kernel for openrisc with allmodconfig the build
> failed with the error:
> drivers/vhost/vhost.c: In function 'vhost_vring_ioctl':
> drivers/vhost/vhost.c:818:3: error: call to '__compiletime_assert_818' declared with attribute error: BUILD_BUG_ON failed: __alignof__
> *vq->avail > VRING_AVAIL_ALIGN_SIZE
> 
> Can you please give me any idea about what the problem might be and how
> it can be solved.
> 
> You can see the build log at:
> https://travis-ci.org/sudipm-mukherjee/parport/jobs/80365425
> 
> regards
> sudip

Yes - I think I saw this already.
I think the openrisc cross-compiler is broken.

VRING_AVAIL_ALIGN_SIZE is 2

*vq->avail is:

struct vring_avail {
        __virtio16 flags;
        __virtio16 idx;
        __virtio16 ring[];
};

And __virtio16 is just a u16 with some sparse annotations.

Looking at openrisc architecture document:
	Operand:		Length		addr[3:0] if aligned
	Halfword (or half) 	2 bytes 	Xxx0

Type	C-TYPE        Sizeof Alignment Openrisc Equivalent
Short   Signed short    2      2       Signed halfword

and

16.1.2
Aggregates and Unions
Aggregates (structures and arrays) and unions assume the alignment of their most
strictly aligned element.

So to me, it looks like your gcc violates the ABI
by adding alignment requirements > 2.

-- 
MST
