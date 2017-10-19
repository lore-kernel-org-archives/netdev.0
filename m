From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] lib/dynamic_queue_limits.c: relax BUG_ON to WARN_ON in
 dql_complete()
Date: Thu, 19 Oct 2017 11:57:56 +0100 (WEST)
Message-ID: <20171019.115756.1156159427863267036.davem@davemloft.net>
References: <20171018154515.16751-1-ard.biesheuvel@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: ard.biesheuvel@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171018154515.16751-1-ard.biesheuvel@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Wed, 18 Oct 2017 16:45:15 +0100

> Even though calling dql_completed() with a count that exceeds the
> queued count is a serious error, it still does not justify bringing
> down the entire kernel with a BUG_ON(). So relax it to a WARN_ON()
> instead.
> 
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

This is bogus.

Unless you are going to do all of the work necessary to fix
the out-of-bounds condition here, you cannot safely continue
into the rest of this function.

Things are going to explode in many places if you don't, at
a minimum, fix the 'count' value to be in range.

But like others I don't like this, the driver needs to be fixed
urgently if this condition triggers.

Sorry I'm not applying this.
