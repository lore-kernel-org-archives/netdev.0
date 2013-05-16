From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] vhost-scsi: Depend on NET for memcpy_fromiovec
Date: Wed, 15 May 2013 20:55:05 -0700
Message-ID: <1368676505.2194.47.camel@joe-AO722>
References: <20130515095558.918f2b29ba318a477eb5dde2@canb.auug.org.au>
	 <1368579583-13097-1-git-send-email-asias@redhat.com>
	 <8761yk254u.fsf@rustcorp.com.au> <20130516020848.GB23441@hj.localdomain>
	 <87d2sra97h.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Asias He <asias@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	target-devel@vger.kernel.org,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Randy Dunlap <rdunlap@infradead.org>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <87d2sra97h.fsf@rustcorp.com.au>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-05-16 at 13:04 +0930, Rusty Russell wrote:
> Asias He <asias@redhat.com> writes:
> > On Wed, May 15, 2013 at 02:47:53PM +0930, Rusty Russell wrote:
[]
> > Other users are using memcpy_fromiovec and friends outside net. It seems
> > a good idea to put it in a util library. e.g.  crypto/algif_skcipher.c
> > which also depends on NET for it.

[]
> Subject: Hoist memcpy_fromiovec into lib/

You'll need the "friends" memcpy_toiovec too.

$ git grep -E \bmemcpy\w+iovec\w*"
crypto/algif_hash.c:    err = memcpy_toiovec(msg->msg_iov, ctx->result, len);
crypto/algif_skcipher.c:                        err = memcpy_fromiovec(page_address(sg_page(sg)) +
crypto/algif_skcipher.c:                        err = memcpy_fromiovec(page_address(sg_page(sg + i)),
drivers/dma/iovlock.c:#include <net/tcp.h> /* for memcpy_toiovec */
drivers/dma/iovlock.c:          return memcpy_toiovec(iov, kdata, len);
drivers/dma/iovlock.c:          err = memcpy_toiovec(iov, vaddr + offset, len);
drivers/isdn/mISDN/socket.c:    if (memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len)) {
drivers/misc/vmw_vmci/vmci_queue_pair.c:                        err = memcpy_fromiovec((u8 *)va + page_o
drivers/misc/vmw_vmci/vmci_queue_pair.c:                        err = memcpy_toiovec(iov, (u8 *)va + pag
