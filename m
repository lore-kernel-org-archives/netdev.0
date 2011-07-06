From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH V8 2/4 net-next] skbuff: skb supports zero-copy buffers
Date: Wed, 06 Jul 2011 16:24:14 -0700
Message-ID: <1309994654.10209.29.camel@localhost.localdomain>
References: <1309990932.10209.19.camel@localhost.localdomain>
	 <4E14E939.5040904@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, mst@redhat.com,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Zan Lynx <zlynx@acm.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4E14E939.5040904@acm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-07-06 at 17:01 -0600, Zan Lynx wrote:
> On 7/6/2011 4:22 PM, Shirley Ma wrote:
> > This patch adds userspace buffers support in skb shared info. A new 
> > struct skb_ubuf_info is needed to maintain the userspace buffers
> > argument and index, a callback is used to notify userspace to
> release
> > the buffers once lower device has done DMA (Last reference to that
> skb
> > has gone).
> > 
> > If there is any userspace apps to reference these userspace buffers,
> > then these userspaces buffers will be copied into kernel. This way
> we
> > can prevent userspace apps from holding these userspace buffers too
> long.
> > 
> > Use destructor_arg to point to the userspace buffer info; a new tx
> flags
> > SKBTX_DEV_ZEROCOPY is added for zero-copy buffer check.
> > 
> > Signed-off-by: Shirley Ma <xma@...ibm.com>
> 
> I was just reading this patch and noticed that you check if
> uarg->callback is set before calling it in skb_release_data, but you
> do
> not check before calling it in skb_copy_ubufs.
> 
> I was only skimming so I have probably missed something...

It is a redundant check. The userspace buffer info always has a callback
to release the buffers. I should have removed it after using tx_flags.

Thanks
Shirley
