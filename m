From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] net: ip, diag -- Add diag interface for raw sockets
Date: Fri, 9 Sep 2016 23:17:31 +0300
Message-ID: <20160909201731.GD2366@uranus.lan>
References: <20160909182636.GC2366@uranus.lan>
 <1473450913.18970.59.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NETDEV <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Andrey Vagin <avagin@openvz.org>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1473450913.18970.59.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 09, 2016 at 12:55:13PM -0700, Eric Dumazet wrote:
> > +
> > +	rep = nlmsg_new(sizeof(struct inet_diag_msg) +
> > +			sizeof(struct inet_diag_meminfo) + 64,
> > +			GFP_KERNEL);
> > +	if (!rep)
> 
> There is a missing sock_put(sk)
> 
> > +		return -ENOMEM;
> > +
> > +	err = inet_sk_diag_fill(sk, NULL, rep, r,
> > +				sk_user_ns(NETLINK_CB(in_skb).sk),
> > +				NETLINK_CB(in_skb).portid,
> > +				nlh->nlmsg_seq, 0, nlh);
> 
> sock_put(sk);

Oh, missed. Thanks lot, Eric, will update!
