From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: NULL pointer dereference in xt_register_target()
Date: Wed, 5 Sep 2012 18:48:31 +0200
Message-ID: <20120905164831.GA21836@1984>
References: <CAM_iQpVUZ50RYLUgEHbcm7ua996hgE7Gj-P-bWNJutuvm1nUoQ@mail.gmail.com>
 <1346860506.13121.148.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netfilter-devel@vger.kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1346860506.13121.148.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 05, 2012 at 05:55:06PM +0200, Eric Dumazet wrote:
> On Wed, 2012-09-05 at 23:43 +0800, Cong Wang wrote:
> > Hi, folks,
> > 
> > The latest net-next tree can't boot due to a NULL ptr def
> > bug in the kernel, the full backtrack is:
> > 
> > http://img1.douban.com/view/photo/photo/public/p1697139550.jpg
> > 
> > the kernel .config file is:
> > 
> > http://pastebin.com/9YTnkqKN
> > 
> > I don't have time to look into the issue. If you need other info,
> > please let me know.
> 
> It seems xt_nat_init() is called before xt_init(), so xt array is not
> yet setup.

I have enqueued the following patch to fix this:

http://1984.lsi.us.es/git/nf-next/commit/?id=00545bec9412d130c77f72a08d6c8b6ad21d4a1
e
commit 00545bec9412d130c77f72a08d6c8b6ad21d4a1e
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Wed Sep 5 18:24:55 2012 +0200

    netfilter: fix crash during boot if NAT has been compiled built-in

Thanks.
