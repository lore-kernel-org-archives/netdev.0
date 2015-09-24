From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] netlink: Replace rhash_portid with bound
Date: Thu, 24 Sep 2015 12:11:42 -0700 (PDT)
Message-ID: <20150924.121142.870602292135442487.davem@davemloft.net>
References: <20150921133415.GA1740@gondor.apana.org.au>
	<20150921182022.GB13263@mtj.duckdns.org>
	<20150922033856.GA7851@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tj@kernel.org, cwang@twopensource.com, tom@herbertland.com,
	kafai@fb.com, kernel-team@fb.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, torvalds@linux-foundation.org,
	jiri@resnulli.us, nicolas.dichtel@6wind.com, tgraf@suug.ch,
	sfeldma@gmail.com
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150922033856.GA7851@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 22 Sep 2015 11:38:56 +0800

> The commit 1f770c0a09da855a2b51af6d19de97fb955eca85 ("netlink:
> Fix autobind race condition that leads to zero port ID") created
> some new races that can occur due to inconcsistencies between the
> two port IDs.
> 
> Tejun is right that a barrier is unavoidable.  Therefore I am
> reverting to the original patch that used a boolean to indicate
> that a user netlink socket has been bound.
> 
> Barriers have been added where necessary to ensure that a valid
> portid and the hashed socket is visible.
> 
> I have also changed netlink_insert to only return EBUSY if the
> socket is bound to a portid different to the requested one.  This
> combined with only reading nlk->bound once in netlink_bind fixes
> a race where two threads that bind the socket at the same time
> with different port IDs may both succeed.
> 
> Fixes: 1f770c0a09da ("netlink: Fix autobind race condition that leads to zero port ID")
> Reported-by: Tejun Heo <tj@kernel.org>
> Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I've decided to apply this and queue it up for -stable.

Thanks everyone.
