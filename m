From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v2] random32: avoid attempt to late reseed if in the middle
 of seeding
Date: Thu, 27 Mar 2014 09:52:51 +0100
Message-ID: <5333E6E3.3020907@redhat.com>
References: <1395900095-15254-1-git-send-email-sasha.levin@oracle.com> <1395900095-15254-2-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, hannes@stressinduktion.org,
	tytso@mit.edu
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395900095-15254-2-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/27/2014 07:01 AM, Sasha Levin wrote:
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

Looks better now, thanks!

Fixes: 4af712e8df99 ("random32: add prandom_reseed_late() and call when nonblocking pool becomes initialized")
Acked-by: Daniel Borkmann <dborkman@redhat.com>
