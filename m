From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: tulip: Constify tulip_tbl
Date: Fri, 08 Sep 2017 20:54:12 -0700 (PDT)
Message-ID: <20170908.205412.2183497152163393093.davem@davemloft.net>
References: <20170907193514.GA114400@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jarod@redhat.com, gustavo@embeddedor.com,
        linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170907193514.GA114400@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Thu, 7 Sep 2017 12:35:14 -0700

> It looks like all users of tulip_tbl are reads, so mark this table
> as read-only.
> 
> $ git grep tulip_tbl  # edited to avoid line-wraps...
> interrupt.c: iowrite32(tulip_tbl[tp->chip_id].valid_intrs, ...
> interrupt.c: iowrite32(tulip_tbl[tp->chip_id].valid_intrs&~RxPollInt, ...
> interrupt.c: iowrite32(tulip_tbl[tp->chip_id].valid_intrs, ...
> interrupt.c: iowrite32(tulip_tbl[tp->chip_id].valid_intrs | TimerInt,
> pnic.c:      iowrite32(tulip_tbl[tp->chip_id].valid_intrs, ioaddr + CSR7);
> tulip.h:     extern struct tulip_chip_table tulip_tbl[];
> tulip_core.c:struct tulip_chip_table tulip_tbl[] = {
> tulip_core.c:iowrite32(tulip_tbl[tp->chip_id].valid_intrs, ioaddr + CSR5);
> tulip_core.c:iowrite32(tulip_tbl[tp->chip_id].valid_intrs, ioaddr + CSR7);
> tulip_core.c:setup_timer(&tp->timer, tulip_tbl[tp->chip_id].media_timer,
> tulip_core.c:const char *chip_name = tulip_tbl[chip_idx].chip_name;
> tulip_core.c:if (pci_resource_len (pdev, 0) < tulip_tbl[chip_idx].io_size)
> tulip_core.c:ioaddr =  pci_iomap(..., tulip_tbl[chip_idx].io_size);
> tulip_core.c:tp->flags = tulip_tbl[chip_idx].flags;
> tulip_core.c:setup_timer(&tp->timer, tulip_tbl[tp->chip_id].media_timer,
> tulip_core.c:INIT_WORK(&tp->media_work, tulip_tbl[tp->chip_id].media_task);
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Jarod Wilson <jarod@redhat.com>
> Cc: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
> Cc: netdev@vger.kernel.org
> Cc: linux-parisc@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
