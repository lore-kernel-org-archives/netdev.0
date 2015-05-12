From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] net: deinline netif_tx_stop_all_queues(), remove WARN_ON
 in netif_tx_stop_queue()
Date: Tue, 12 May 2015 09:00:17 -0700
Message-ID: <20150512160016.GA3491@Alexeis-MBP.westell.com>
References: <1431371873-26969-1-git-send-email-dvlasenk@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Joe Perches <joe@perches.com>, Jiri Pirko <jpirko@redhat.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Denys Vlasenko <dvlasenk@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1431371873-26969-1-git-send-email-dvlasenk@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 11, 2015 at 09:17:53PM +0200, Denys Vlasenko wrote:
> These functions compile to 60 bytes of machine code each.
> With this .config: http://busybox.net/~vda/kernel_config
> there are 617 calls of netif_tx_stop_queue()
> and 49 calls of netif_tx_stop_all_queues() in vmlinux.
> 
> To fix this, remove WARN_ON in netif_tx_stop_queue()
> as suggested by davem, and deinline netif_tx_stop_all_queues().
> 
> Change in code size is about 20k:
> 
>    text      data      bss       dec     hex filename
> 82426986 22255416 20627456 125309858 77813a2 vmlinux.before
> 82406248 22255416 20627456 125289120 777c2a0 vmlinux

nice code shrink. Looks good to me.

Acked-by: Alexei Starovoitov <ast@plumgrid.com>

btw, in the future please say [PATCH net-next] as part of subject
to make it clear what tree this patch is going to.
