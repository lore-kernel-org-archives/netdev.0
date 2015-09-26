From: Tejun Heo <tj@kernel.org>
Subject: Re: netlink: Add netlink_bound helper and use it in netlink_getname
Date: Sat, 26 Sep 2015 15:52:45 -0400
Message-ID: <20150926195245.GF3572@htj.duckdns.org>
References: <20150922033856.GA7851@gondor.apana.org.au>
 <20150924.121142.870602292135442487.davem@davemloft.net>
 <20150924200510.GE25415@mtj.duckdns.org>
 <20150925014327.GA3725@gondor.apana.org.au>
 <20150925150113.GD4449@mtj.duckdns.org>
 <20150926131621.GA16724@gondor.apana.org.au>
 <20150926180903.GD3572@htj.duckdns.org>
 <20150926194110.GA18815@gondor.apana.org.au>
 <20150926194554.GE3572@htj.duckdns.org>
 <20150926194916.GA18975@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cwang@twopensource.com,
	tom@herbertland.com, kafai@fb.com, kernel-team@fb.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, jiri@resnulli.us,
	nicolas.dichtel@6wind.com, tgraf@suug.ch, sfeldma@gmail.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150926194916.GA18975@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Sun, Sep 27, 2015 at 03:49:16AM +0800, Herbert Xu wrote:
> If the autobind is not complete then netlink_getname must return
> zero rather than some garbage portid that belongs to somebody
> else's socket.  That's what we did before any of this lockless
> code was introduced.
> 
> If you don't check nlk->bound then you may return garbage.

Ah, yeah, you're right.  We need to check that there because it may
contain a garbage value.  I still think it'd better to use
netlink_bound() test in connect() too tho.

Thanks.

-- 
tejun
