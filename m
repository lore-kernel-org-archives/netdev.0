From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [V2 PATCH 2/9] macvtap: zerocopy: fix truesize underestimation
Date: Fri, 18 May 2012 08:22:31 -0700
Message-ID: <1337354551.12999.6.camel@oc3660625478.ibm.com>
References: <20120502033901.11782.13157.stgit@amd-6168-8-1.englab.nay.redhat.com>
	 <20120502034144.11782.88947.stgit@amd-6168-8-1.englab.nay.redhat.com>
	 <1337102809.8220.10.camel@oc3660625478.ibm.com>
	 <4FB3192E.4030803@redhat.com>
	 <1337180585.10741.6.camel@oc3660625478.ibm.com>
	 <4FB469A1.3040507@redhat.com>
	 <1337268512.10741.53.camel@oc3660625478.ibm.com>
	 <4FB62009.2050900@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com,
	davem@davemloft.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FB62009.2050900@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-05-18 at 18:10 +0800, Jason Wang wrote:
> > On Thu, 2012-05-17 at 10:59 +0800, Jason Wang wrote:
> >> Didn't see how this affact skb->len. And for truesize, I think they
> >> are
> >> different, when the offset were not zero, the data in this vector
> >> were
> >> divided into two parts. First part is copied into skb directly, and
> >> the
> >> second were pinned from a whole userspace page by
> >> get_user_pages_fast(),
> >> so we need count the whole page to the socket limit to prevent evil
> >> application.
> > What I meant that the code for skb->truesize has double added the
> first
> > offset if any left from that vector (partically copied into skb
> > directly, and then count pagesize which includes the offset
> (truesize +=
> > PAGE_SIZE)).
> 
> Yes, I get you mean. There's no difference between first frag and 
> others: it's also possible for other frags that didn't occupy the
> whole 
> page. Since we pin the whole user page, better to count the whole
> page 
> size to prevent evil application. 

The difference between first frags and others is other frags might not
occupy the whole page, but the first frags extra offset was doubled
added in skb truesize.

So it's ok for skb->truesize to be bigger than all the skb pinned pages
here?

Thanks
Shirley
