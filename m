From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: [PATCH 2/5] forcedeth: interrupt handling cleanup
Date: Sat, 6 Oct 2007 21:43:27 -0700
Message-ID: <86802c440710062143x3bb801c3obb91292208073588@mail.gmail.com>
References: <20071006151250.GA17020@havoc.gtf.org>
	 <20071006151400.GB17488@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Ayaz Abdulla" <aabdulla@nvidia.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"Andrew Morton" <akpm@linux-foundation.org>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752532AbXJGEnm@vger.kernel.org>
In-Reply-To: <20071006151400.GB17488@havoc.gtf.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/6/07, Jeff Garzik <jeff@garzik.org> wrote:
>
> commit a606d2a111cdf948da5d69eb1de5526c5c2dafef
> Author: Jeff Garzik <jeff@garzik.org>
> Date:   Fri Oct 5 22:56:05 2007 -0400
>
>     [netdrvr] forcedeth: interrupt handling cleanup
>
>     * nv_nic_irq_optimized() and nv_nic_irq_other() were complete duplicates
>       of nv_nic_irq(), with the exception of one function call.  Consolidate
>       all three into a single interrupt handler, deleting a lot of redundant
>       code.
>
>     * greatly simplify irq handler locking.
>
>       Prior to this change, the irq handler(s) would acquire and release
>       np->lock for each action (RX, TX, other events).
>
>       For the common case -- RX or TX work -- the lock is always acquired,
>       making all successive acquire/release combinations largely redundant.
>
>       Acquire the lock at the beginning of the irq handler, and release it at
>       the end of the irq handler.  This is simple, easy, and obvious.
>
>     * remove irq handler work loop.
>
>       All interesting events emanating from the irq handler either have
>       their own work loops, or they poke a timer into action.
>
>       Therefore, delete the pointless master interrupt handler work loop.
>
>     Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
>
>  drivers/net/forcedeth.c |  325 +++++++++++-------------------------------------
>  1 file changed, 77 insertions(+), 248 deletions(-)
>
any chance to create three verion irq handlers for ioapic, msi, msi-x...?

MACRO or inline function?

YH
