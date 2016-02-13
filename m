From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] hv_netvsc: Restore needed_headroom request
Date: Sat, 13 Feb 2016 06:05:07 -0500 (EST)
Message-ID: <20160213.060507.1405887572923400829.davem@davemloft.net>
References: <1454689748-29095-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, haiyangz@microsoft.com,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: vkuznets@redhat.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1454689748-29095-1-git-send-email-vkuznets@redhat.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Vitaly Kuznetsov <vkuznets@redhat.com>
Date: Fri,  5 Feb 2016 17:29:08 +0100

> Commit c0eb454034aa ("hv_netvsc: Don't ask for additional head room in the
> skb") got rid of needed_headroom setting for the driver. With the change I
> hit the following issue trying to use ptkgen module:
> 
> [   57.522021] kernel BUG at net/core/skbuff.c:1128!
> [   57.522021] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
> ...
> [   58.721068] Call Trace:
> [   58.721068]  [<ffffffffa0144e86>] netvsc_start_xmit+0x4c6/0x8e0 [hv_netvsc]
> ...
> [   58.721068]  [<ffffffffa02f87fc>] ? pktgen_finalize_skb+0x25c/0x2a0 [pktgen]
> [   58.721068]  [<ffffffff814f5760>] ? __netdev_alloc_skb+0xc0/0x100
> [   58.721068]  [<ffffffffa02f9907>] pktgen_thread_worker+0x257/0x1920 [pktgen]
> 
> Basically, we're calling skb_cow_head(skb, RNDIS_AND_PPI_SIZE) and crash on
>     if (skb_shared(skb))
>         BUG();
> 
> We probably need to restore needed_headroom setting (but shrunk to
> RNDIS_AND_PPI_SIZE as we don't need more) to request the required headroom
> space. In theory, it should not give us performance penalty.
> 
> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>

Applied, thanks.
