From: Dan Carpenter <error27@gmail.com>
Subject: Re: [PATCH] Ceph: Fix a use-after-free bug in
 ceph_destroy_client().
Date: Sun, 26 Dec 2010 01:46:58 +0300
Message-ID: <20101225224658.GC19019@bicker>
References: <alpine.LNX.2.00.1012251914370.10759@swampdragon.chaosbits.net>
 <AANLkTik+yrpY8T69w_RQ84ZbRqwkjvFhvxHLBvU14N3f@mail.gmail.com>
 <alpine.LNX.2.00.1012252223380.10759@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: richard -rw- weinberger <richard.weinberger@gmail.com>,
	ceph-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Sage Weil <sage@newdream.net>,
	"David S. Miller" <davem@davemloft.net>
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1012252223380.10759@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 25, 2010 at 10:24:57PM +0100, Jesper Juhl wrote:
> On Sat, 25 Dec 2010, richard -rw- weinberger wrote:
> 
> > On Sat, Dec 25, 2010 at 7:17 PM, Jesper Juhl <jj@chaosbits.net> wrote:
> > > Hello,
> > >
> > > In net/ceph/ceph_common.c::ceph_destroy_client() the pointer 'client' is
> > > freed by kfree() and subsequently used in a call to dout() - use after
> > > free bug.
> > 
> > Not really. %p reads only the address of "client".
> > kfree() does not alter this address.
> > 
> 
> Ok, I see your point and you are correct. But still, the patch does not 
> change behaviour and it makes it absolutely clear that there's no 
> use-after-free bug, so it might still have merit... or?
> 

I see these with Smatch as well.  This type of usage is quite common.
People do it deliberately and I guess they feel it's readable.  Don't
change them.

If it were something that a static checker couldn't figure out, then
I'd say change it, but really the static checkers should just be made
smarter.  Some day I'm going to make Smatch complain if it's a %s in
the string instead of a %p, but for now I just ignore the false
positives.

regards,
dan carpenter
