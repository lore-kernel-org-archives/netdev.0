From: Cong Wang <amwang@redhat.com>
Subject: Re: [RFC Patch net-next 3/5] inetpeer: use generic union inet_addr
Date: Mon, 01 Jul 2013 16:40:49 +0800
Message-ID: <1372668049.2974.25.camel@cr0>
References: <1372315398-19683-1-git-send-email-amwang@redhat.com>
	 <1372315398-19683-4-git-send-email-amwang@redhat.com>
	 <1372320082.3301.217.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372320082.3301.217.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-06-27 at 01:01 -0700, Eric Dumazet wrote:
> On Thu, 2013-06-27 at 14:43 +0800, Cong Wang wrote:
> >  struct inet_peer {
> >  	/* group together avl_left,avl_right,v4daddr to speedup lookups */
> >  	struct inet_peer __rcu	*avl_left, *avl_right;
> > -	struct inetpeer_addr	daddr;
> > +	union inet_addr		daddr;
> 
> Please compare sizeof(struct inetpeer_addr) and sizeof(union inet_addr)
> 
> If I am not mistaken, its 20 bytes instead of 28
> 
> Yes, sockaddr_in6 is a bit bloated...
> 

You are right.

Are you saying that I should rearrange the fields of struct inet_peer in
case of cacheline miss?

Thanks!
