From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: don't copy over empty attribute data
Date: Tue, 21 Oct 2014 21:39:08 -0400 (EDT)
Message-ID: <20141021.213908.1088381802543942481.davem@davemloft.net>
References: <1413924669-26732-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: a.ryabinin@samsung.com, pablo@netfilter.org, mschmidt@redhat.com,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: sasha.levin@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413924669-26732-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sasha Levin <sasha.levin@oracle.com>
Date: Tue, 21 Oct 2014 16:51:09 -0400

> netlink uses empty data to seperate different levels. However, we still
> try to copy that data from a NULL ptr using memcpy, which is an undefined
> behaviour.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

This isn't a POSIX C library, this it the Linux kernel, and as such
we can make sure none of our memcpy() implementations try to access
any bytes if the given length is NULL.

And to be quite honest, there is no benefit whatsoever nor even the
possibility of using that "undefined behavior" flexibility to do
anthing. This is because every memcpy() implementation must be sure
not to access past the end of either source or destination buffer.

And the one and only way to do that is to respect the length.

I'm not applying this, because the basis for which this is claimed
to be a bug fix is quite bogus in my opinion.

Sorry.
