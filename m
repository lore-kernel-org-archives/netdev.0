From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: linux-next: build failure after merge of the final tree
Date: Mon, 23 May 2011 22:06:40 -0400
Message-ID: <BANLkTimjzzqTS1fELmpb0UivqseLsYOfPw@mail.gmail.com>
References: <20110520161816.dda6f1fd.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linus <torvalds@linux-foundation.org>, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	linux-fsdevel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Dipankar Sarma <dipankar@in.ibm.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20110520161816.dda6f1fd.sfr@canb.auug.org.au>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 20, 2011 at 02:18, Stephen Rothwell wrote:
> Caused by commit e66eed651fd1 ("list: remove prefetching from regular list
> iterators").
>
> I added the following patch for today:

probably should get added to whatever tree that commit is coming from
so we dont have bisect hell ?

more failures:
drivers/usb/host/isp1362-hcd.c: In function 'isp1362_write_ptd':
drivers/usb/host/isp1362-hcd.c:355: error: implicit declaration of
function 'prefetch'
drivers/usb/host/isp1362-hcd.c: In function 'isp1362_read_ptd':
drivers/usb/host/isp1362-hcd.c:377: error: implicit declaration of
function 'prefetchw'
make[3]: *** [drivers/usb/host/isp1362-hcd.o] Error 1

drivers/usb/musb/musb_core.c: In function 'musb_write_fifo':
drivers/usb/musb/musb_core.c:219: error: implicit declaration of
function 'prefetch'
make[3]: *** [drivers/usb/musb/musb_core.o] Error 1

although it seems like it should be fairly trivial to look at the
funcs in linux/prefetch.h, grep the tree, and find a pretty good list
of the files that are missing the include
-mike
