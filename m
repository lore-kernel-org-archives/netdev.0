From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/6] macvtap: zerocopy: fix truesize underestimation
Date: Mon, 16 Apr 2012 10:49:53 +0200
Message-ID: <1334566193.28012.66.camel@edumazet-glaptop>
References: <20120416060749.14140.19433.stgit@intel-e5620-16-2.englab.nay.redhat.com>
	 <20120416060758.14140.40252.stgit@intel-e5620-16-2.englab.nay.redhat.com>
	 <20120416071423.GA25396@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
	xma@us.ibm.com, davem@davemloft.net, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120416071423.GA25396@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-04-16 at 10:14 +0300, Michael S. Tsirkin wrote:
> On Mon, Apr 16, 2012 at 02:07:59PM +0800, Jason Wang wrote:
> > As the skb fragment were pinned/built from user pages, we should
> > account the page instead of length for truesize.
> > 
> > Signed-off-by: Jason Wang <jasowang@redhat.com>
> 
> I'm not sure this is right: the skb does *not* consume the
> whole page, userspace uses the rest of the page
> for other skbs. So we'll end up accounting for the
> same page twice.
> Eric, what's the right thing to do here in your opinion?

Problem is we dont know for sure userspace wont free pages right after
this syscall. So an evil application could consume more kernel memory
than what socket limit allowed.

Its same problem with vmsplice(mem -> pipe) + splice(pipe -> socket)

When we clone skb with frags, resulting skb will have same truesize,
even if the pages are shared ...
