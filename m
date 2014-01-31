From: Tejun Heo <tj@kernel.org>
Subject: Re: Suspected Copy Paste error in rtnl_bridge_notify
Date: Fri, 31 Jan 2014 06:47:12 -0500
Message-ID: <20140131114712.GB26148@htj.dyndns.org>
References: <CAG6enPwAfm8YDrGmEEitv_fHeF5rVVN2nXujh=u4kVy0sKx4ag@mail.gmail.com>
 <CAG6enPyV9bvYSwDrMp6X1LY6PXrmrP5MtjNk0N+7qs1LDY5pRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Yogesh Gaur <yogeshgaur.83@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAG6enPyV9bvYSwDrMp6X1LY6PXrmrP5MtjNk0N+7qs1LDY5pRg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey,

Seems suspicious but I don't know the code at all.  cc'ing David and
netdev and quoting the whole body for them.

Thanks.

On Fri, Jan 31, 2014 at 11:32:55AM +0530, Yogesh Gaur wrote:
> Hello All,
> 
> I want to clarify about following code-snippet from
> file: "net/core/rtnetlink.c"
> func: rtnl_bridge_notify
> 
> ----------------------------------------------------------------------------
> |    if ((!flags || (flags & BRIDGE_FLAGS_MASTER)) && |
> |        br_dev && br_dev->netdev_ops->ndo_bridge_getlink) {
> |
> |        err = br_dev->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev, 0);
> |
> |        if (err < 0)
> |
> |            goto errout;
> |
> |    }
> |
> |
> |
> |    if ((flags & BRIDGE_FLAGS_SELF) &&
> |
> |        dev->netdev_ops->ndo_bridge_getlink) {
> |
> |        err = dev->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev, 0);
> |
> |        if (err < 0)
> |
> |            goto errout;
> |
> ----------------------------------------------------------------------------
> 
> In above code isn't code line:
> err = br_dev->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev, 0);
> should be
> err = br_dev->netdev_ops->ndo_bridge_getlink(skb, 0, 0, br_dev, 0);
> 
> If this needs to be changed then please review attached patch adding this
> change.

-- 
tejun
