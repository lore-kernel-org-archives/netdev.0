From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [PATCH v2 2/2] virtio-net: Prevent NULL dereference
Date: Sat, 08 Oct 2011 10:40:11 +0200
Message-ID: <1318063211.7385.1.camel@lappy>
References: <1317220855-9352-1-git-send-email-levinsasha928@gmail.com>
	 <1317220855-9352-2-git-send-email-levinsasha928@gmail.com>
	 <20111003190516.GD22427@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20111003190516.GD22427@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-10-03 at 21:05 +0200, Michael S. Tsirkin wrote:
> I thought about this some more. If length was too large host is
> right now writing into pages that we have freed.
> That is very bad, and I don't know what do do with it,
> really not worth prettifying that IMO, NULL pointer is the least of our
> worries.
> 
> But, with mergeable buffers at least, and that is the main mode anyway,
> there is always a single page per buf, right?
> So I think we should change the code,
> and for mergeable buffers we shall only verify that
> length <= PAGE_SIZE.

In receive_mergeable() we already verify both 'page' being non-null and
length:

	if (len > PAGE_SIZE)
		len = PAGE_SIZE;

> 
> IOW copy a bit of code from page_to_skb(vi, page, len)
> to receive_mergeable, maybe add a common function
> if we need to avoid duplication.

-- 

Sasha.

