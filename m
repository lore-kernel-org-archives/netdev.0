From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v2] rsi: Fix failure to load firmware after memory leak fix and
 fixthe leak
Date: Fri, 31 Jul 2015 06:23:12 +0000 (UTC)
Message-ID: <20150731062312.CF880140A4E@smtp.codeaurora.org>
References: <1438062661-3173-1-git-send-email-mike.looijmans@topic.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, khoroshilov@ispras.ru,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mike Looijmans <mike.looijmans@topic.nl>,
	stable@vger.kernel.org
To: Mike Looijmans <mike.looijmans@topic.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438062661-3173-1-git-send-email-mike.looijmans@topic.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Fixes commit eae79b4f3e82 ("rsi: fix memory leak in rsi_load_ta_instructions()")
> which stopped the driver from functioning.
> 
> Firmware data has been allocated using vmalloc(), resulting in memory
> that cannot be used for DMA. Hence the firmware was first copied to a
> buffer allocated with kmalloc() in the original code. This patch reverts
> the commit and only calls "kfree()" to release the buffer after sending
> the data. This fixes the memory leak without breaking the driver.
> 
> Add a comment to the kmemdup() calls to explain why this is done, and abort
> if memory allocation fails.
> 
> Tested on a Topic Miami-Florida board which contains the rsi SDIO chip.
> 
> Also added the same kfree() call to the USB glue driver. This was not
> tested on actual hardware though, as I only have the SDIO version.
> 
> Fixes: eae79b4f3e82 ("rsi: fix memory leak in rsi_load_ta_instructions()")
> Signed-off-by: Mike Looijmans <mike.looijmans@topic.nl>
> Cc: stable@vger.kernel.org

Thanks, applied to wireless-drivers.git.

Kalle Valo
