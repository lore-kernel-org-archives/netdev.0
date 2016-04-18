From: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH V2] net: ethernet: mellanox: correct page conversion
Date: Mon, 18 Apr 2016 08:40:58 -0700
Message-ID: <20160418154058.GA4228@infradead.org>
References: <1460845412-13120-1-git-send-email-okaya@codeaurora.org>
 <20160418065447.GA11539@x-vnc01.mtx.labs.mlnx>
 <20160418143255.GA15203@infradead.org>
 <DB5PR05MB1848424EC9DC8D4150EADB03C56B0@DB5PR05MB1848.eurprd05.prod.outlook.com>
 <20160418151702.GA26565@infradead.org>
 <5714FB68.3020604@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org" <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org" <cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Sinan Kaya <okaya-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5714FB68.3020604-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 18, 2016 at 11:21:12AM -0400, Sinan Kaya wrote:
> I was looking at the code. I don't see how removing virt_to_page + vmap 
> would solve the issue.
> 
> The code is trying to access the buffer space with direct.buf member
> from the CPU side. This member would become NULL, when this code is 
> removed and also in mlx4_en_map_buffer. 
>
> ...
>
> What am I missing?

As mentioned before you'll also need to enforce you hit the nbufs = 1
case for these.  In fact most callers should simply switch to a plain
dma_zalloc_coherent call without all these wrappers.  If we have a case
where we really want multiple buffers that don't have to be contiguous
(maybe the MTT case) I'd rather opencode that instead of building this
confusing interface on top of it.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
