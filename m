From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v3 12/18] crypto: switch af_alg_make_sg() to iov_iter
Date: Mon, 9 Feb 2015 17:30:31 +0000
Message-ID: <20150209173031.GA29656@ZenIV.linux.org.uk>
References: <20150204063730.GG29656@ZenIV.linux.org.uk>
 <1423032009-18367-12-git-send-email-viro@ZenIV.linux.org.uk>
 <1830853.QH0ahQU9zL@tachyon.chronox.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Stephan Mueller <smueller@chronox.de>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1830853.QH0ahQU9zL@tachyon.chronox.de>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 09, 2015 at 02:59:40PM +0100, Stephan Mueller wrote:
> Am Mittwoch, 4. Februar 2015, 06:40:03 schrieb Al Viro:
> 
> Hi Al,
> 
> > From: Al Viro <viro@zeniv.linux.org.uk>
> > 
> > With that, all ->sendmsg() instances are converted to iov_iter primitives
> > and are agnostic wrt the kind of iov_iter they are working with.
> > So's the last remaining ->recvmsg() instance that wasn't kind-agnostic yet.
> > All ->sendmsg() and ->recvmsg() advance ->msg_iter by the amount actually
> > copied and none of them modifies the underlying iovec, etc.
> 
> After testing this patch with the test application by simply executing 
> [1]/test/test.sh, the hash and skcipher interface invocation hang in kernel 
> space. Though, I am not sure where the problem is.
> 
> For individual invocations of the tests, you may look into [1]/test/kcapi-
> main.c in the comments above cavs_sym or cavs_hash.
> 
> [1] http://www.chronox.de/libkcapi.html

Very interesting; I'll try to reproduce it once I get some sleep (up since
yesterday, and it's past noon here ;-/)
