From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: ethernet: broadcom: fix improper return value
Date: Mon, 05 Dec 2016 14:59:26 -0500 (EST)
Message-ID: <20161205.145926.1120588530863327322.davem@davemloft.net>
References: <1480832969-5888-1-git-send-email-bianpan201604@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@cavium.com, ariel.elior@cavium.com,
        everest-linux-l2@cavium.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, bianpan2016@163.com
To: bianpan201604@163.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480832969-5888-1-git-send-email-bianpan201604@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pan Bian <bianpan201604@163.com>
Date: Sun,  4 Dec 2016 14:29:29 +0800

> From: Pan Bian <bianpan2016@163.com>
> 
> Marco BNX2X_ALLOC_AND_SET(arr, lbl, func) calls kmalloc() to allocate
> memory, and jumps to label "lbl" if the allocation fails. Label "lbl"
> first cleans memory and then returns variable rc. Before calling the
> macro, the value of variable rc is 0. Because 0 means no error, the
> callers of bnx2x_init_firmware() may be misled. This patch fixes the bug,
> assigning "-ENOMEM" to rc before calling macro NX2X_ALLOC_AND_SET().
> 
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=189141
> 
> Signed-off-by: Pan Bian <bianpan2016@163.com>

Applied, but...

> @@ -13505,6 +13505,7 @@ static int bnx2x_init_firmware(struct bnx2x *bp)
>  
>  	/* Initialize the pointers to the init arrays */
>  	/* Blob */
> +	rc = -ENOMEM;
>  	BNX2X_ALLOC_AND_SET(init_data, request_firmware_exit, be32_to_cpu_n);
>  
>  	/* Opcodes */

These kinds of macros which internally change control flow should always
be avoided.
