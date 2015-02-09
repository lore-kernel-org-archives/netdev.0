From: Stephan Mueller <smueller@chronox.de>
Subject: Re: [PATCH v3 12/18] crypto: switch af_alg_make_sg() to iov_iter
Date: Mon, 09 Feb 2015 14:59:40 +0100
Message-ID: <1830853.QH0ahQU9zL@tachyon.chronox.de>
References: <20150204063730.GG29656@ZenIV.linux.org.uk> <1423032009-18367-12-git-send-email-viro@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1423032009-18367-12-git-send-email-viro@ZenIV.linux.org.uk>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, 4. Februar 2015, 06:40:03 schrieb Al Viro:

Hi Al,

> From: Al Viro <viro@zeniv.linux.org.uk>
> 
> With that, all ->sendmsg() instances are converted to iov_iter primitives
> and are agnostic wrt the kind of iov_iter they are working with.
> So's the last remaining ->recvmsg() instance that wasn't kind-agnostic yet.
> All ->sendmsg() and ->recvmsg() advance ->msg_iter by the amount actually
> copied and none of them modifies the underlying iovec, etc.

After testing this patch with the test application by simply executing 
[1]/test/test.sh, the hash and skcipher interface invocation hang in kernel 
space. Though, I am not sure where the problem is.

For individual invocations of the tests, you may look into [1]/test/kcapi-
main.c in the comments above cavs_sym or cavs_hash.

[1] http://www.chronox.de/libkcapi.html
-- 
Ciao
Stephan
