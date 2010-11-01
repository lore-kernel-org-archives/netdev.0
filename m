From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] tun: remove of user-controlled memory allocation
Date: Mon, 01 Nov 2010 07:16:48 -0700 (PDT)
Message-ID: <20101101.071648.112608839.davem@davemloft.net>
References: <20101101082749.GA25860@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, eric.dumazet@gmail.com,
	joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101101082749.GA25860@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Mon, 1 Nov 2010 10:27:49 +0200

> Untested, this is just an RFC.
> 
> tun does a kmalloc where userspace controls the length. This will
> produce warnings in kernel log when the length is too large, or might
> block for a long while. A simple fix is to avoid the allocatiuon
> altogether, and copy from user in a loop.
> 
> However, with this patch an illegal address passed to the ioctl might
> leave the filter disabled.  Is this something we care about?  If
> yes we could recover by creating a copy of the filter.  Thoughts?
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

I think the key issue in situations like this is simply to make
sure that reasonable things that worked before, still do afterwards.

And I think your patch does that, so it's fine as far as I can tell.
