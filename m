From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv2 net-next 1/8] skb: report completion status for zero
	copy skbs
Date: Thu, 1 Nov 2012 18:16:11 +0200
Message-ID: <20121101161611.GA9410@redhat.com>
References: <cover.1351679008.git.mst@redhat.com>
	<0dc176ed796ff5ac7164b6c18cc75d64c2a2317e.1351679008.git.mst@redhat.com>
	<20121101.115024.1422610516561380154.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, alexander.h.duyck@intel.com, Ian.Campbell@citrix.com,
	kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20121101.115024.1422610516561380154.davem@davemloft.net>
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

On Thu, Nov 01, 2012 at 11:50:24AM -0400, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Wed, 31 Oct 2012 12:31:06 +0200
> 
> > -void vhost_zerocopy_callback(struct ubuf_info *ubuf)
> > +void vhost_zerocopy_callback(struct ubuf_info *ubuf, int zerocopy_status)
> 
> If you're only reporting true/false values, even just for now,
> please use 'bool' for this.

In fact next patch reports -ENOMEM when tun hits OOM so callback can
distinguish between copy (>0 value) and error (<0 value)
and reduce zerocopy more aggressively in case of errors.

The *callback* in vhost-net currently handles all non-zero
values identically, but I am not sure it's the optimal behaviour
so I thought it's worth it to give callbacks the info.

Do you think it's over-engineering, or a good idea?

-- 
MST
