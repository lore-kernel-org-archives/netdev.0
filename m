From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Possible netlink autobind regression
Date: Thu, 17 Sep 2015 13:25:05 +0200
Message-ID: <20150917112505.GA27604@pox.localdomain>
References: <20150917022909.GA22754@htj.duckdns.org>
 <20150917030845.GA19162@gondor.apana.org.au>
 <20150917034134.GA19327@gondor.apana.org.au>
 <CAHA+R7OdJyZiidHarKhp-U6R5fkHj=5KjugK=XoWj=q4D8krxw@mail.gmail.com>
 <20150917051503.GA19978@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <cwang@twopensource.com>, Tejun Heo <tj@kernel.org>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>, kafai@fb.com,
	kernel-team <kernel-team@fb.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jiri Pirko <jiri@resnulli.us>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Scott Feldman <sfeldma@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150917051503.GA19978@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/17/15 at 01:15pm, Herbert Xu wrote:
> On Wed, Sep 16, 2015 at 10:02:00PM -0700, Cong Wang wrote:
> >
> > This part doesn't look correct, seems it is checking if this is a kernel
> > netlink socket rather than if it is bound. But I am not sure...
> 
> Good point.  I've changed it so that bound is only set for non-kernel
> sockets.
> 
> ---8<---
> netlink: Fix autobind race condition that leads to zero port ID
> 
> The commit c0bb07df7d981e4091432754e30c9c720e2c0c78 ("netlink:
> Reset portid after netlink_insert failure") introduced a race
> condition where if two threads tried to autobind the same socket
> one of them may end up with a zero port ID.
> 
> This patch reverts that commit and instead fixes it by introducing
> a separte "bound" variable to indicate whether a user-space socket
> has been bound.
> 
> Fixes: c0bb07df7d98 ("netlink: Reset portid after netlink_insert failure")
> Reported-by: Tejun Heo <tj@kernel.org>
> Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> Reviewed-by: Cong Wang <cwang@twopensource.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
