From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [PATCH] Ceph: Fix a use-after-free bug in
 ceph_destroy_client().
Date: Sat, 25 Dec 2010 22:24:57 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1012252223380.10759@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1012251914370.10759@swampdragon.chaosbits.net> <AANLkTik+yrpY8T69w_RQ84ZbRqwkjvFhvxHLBvU14N3f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ceph-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Sage Weil <sage@newdream.net>,
	"David S. Miller" <davem@davemloft.net>
To: richard -rw- weinberger <richard.weinberger@gmail.com>
Return-path: <ceph-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTik+yrpY8T69w_RQ84ZbRqwkjvFhvxHLBvU14N3f@mail.gmail.com>
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 25 Dec 2010, richard -rw- weinberger wrote:

> On Sat, Dec 25, 2010 at 7:17 PM, Jesper Juhl <jj@chaosbits.net> wrote:
> > Hello,
> >
> > In net/ceph/ceph_common.c::ceph_destroy_client() the pointer 'client' is
> > freed by kfree() and subsequently used in a call to dout() - use after
> > free bug.
> 
> Not really. %p reads only the address of "client".
> kfree() does not alter this address.
> 

Ok, I see your point and you are correct. But still, the patch does not 
change behaviour and it makes it absolutely clear that there's no 
use-after-free bug, so it might still have merit... or?

-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

