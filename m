From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] net: sock: validate data_len before allocating skb in
 sock_alloc_send_pskb()
Date: Thu, 31 May 2012 09:02:03 +0300
Message-ID: <20120531060201.GA13158@redhat.com>
References: <20120530054702.6146.8503.stgit@amd-6168-8-1.englab.nay.redhat.com>
 <1338360383.2760.84.camel@edumazet-glaptop>
 <20120530.030205.1337682162603770949.davem@davemloft.net>
 <4FC708EE.2020908@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4FC708EE.2020908@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 31, 2012 at 02:00:14PM +0800, Jason Wang wrote:
> On 05/30/2012 03:02 PM, David Miller wrote:
> >From: Eric Dumazet<eric.dumazet@gmail.com>
> >Date: Wed, 30 May 2012 08:46:23 +0200
> >
> >>Why doing this test in the while (1) block, it should be done before the
> >>loop...
> >>
> >>Or even in the caller, note net/unix/af_unix.c does this right.
> >>
> >>         if (len>  SKB_MAX_ALLOC)
> >>                 data_len = min_t(size_t,
> >>                                  len - SKB_MAX_ALLOC,
> >>                                  MAX_SKB_FRAGS * PAGE_SIZE);
> >>
> >>         skb = sock_alloc_send_pskb(sk, len - data_len, data_len,
> >>                                    msg->msg_flags&  MSG_DONTWAIT,&err);
> >My impression is that the callers should be fixed to.  It makes no sense
> >to penalize the call sites that get this right.
> >
> >And yes, if we do check it in sock_alloc_send_pskb() it should be done
> >at function entry, not inside the loop.
> 
> Sure, so is it ok for me to send a V2 that just do the fixing in
> sock_alloc_sned_pskb() as it's simple and easy to be accepted by
> stable version?
> 
> For the fix of callers, I want to post fixes on top as I find
> there's some code duplication of {tun|macvtap|packet}_alloc_skb()
> and I want to unify them to a common helper in sock.c. Then I can
> fix this issue in the new helper.

Are packet sockets really affected?
If yes the only call site that gets this right is unix sockets?

> >--
> >To unsubscribe from this list: send the line "unsubscribe netdev" in
> >the body of a message to majordomo@vger.kernel.org
> >More majordomo info at  http://vger.kernel.org/majordomo-info.html
