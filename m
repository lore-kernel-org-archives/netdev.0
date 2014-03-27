From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] random32: avoid attempt to late reseed if in the middle of seeding
Date: Thu, 27 Mar 2014 07:17:42 +0100
Message-ID: <20140327061742.GM22086@order.stressinduktion.org>
References: <1395900095-15254-1-git-send-email-sasha.levin@oracle.com> <1395900095-15254-2-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tytso@mit.edu, dborkman@redhat.com
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1395900095-15254-2-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 27, 2014 at 02:01:35AM -0400, Sasha Levin wrote:
> Commit 4af712e8df ("random32: add prandom_reseed_late() and call when
> nonblocking pool becomes initialized") has added a late reseed stage
> that happens as soon as the nonblocking pool is marked as initialized.
> 
> This fails in the case that the nonblocking pool gets initialized
> during __prandom_reseed()'s call to get_random_bytes(). In that case
> we'd double back into __prandom_reseed() in an attempt to do a late
> reseed - deadlocking on 'lock' early on in the boot process.
> 
> Instead, just avoid even waiting to do a reseed if a reseed is already
> occuring.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Thanks for fixing this!

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
