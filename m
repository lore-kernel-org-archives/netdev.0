From: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2] iwl4965: Fix a null pointer dereference in
 il_tx_queue_free and il_cmd_queue_free
Date: Mon, 11 Jan 2016 15:04:31 +0100
Message-ID: <20160111140431.GB26139@redhat.com>
References: <1452519775-7049-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	linuxwifi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1452519775-7049-1-git-send-email-baijiaju1990-9Onoh4P/yGk@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 11, 2016 at 09:42:54PM +0800, Jia-Ju Bai wrote:
> If "txq->cmd = kzalloc(...)" in il_tx_queue_init fails,
> "kfree(txq->cmd[i])" in il_tx_queue_free and il_cmd_queue_free
> in iwl4965_hw_txq_ctx_free will causes a null pointer dereference,
> because txq->cmd is NULL at that time.
> 
> This patch fixes this problem by adding a if-check before kfree.
> To avoid double free in il_tx_queue_free and il_cmd_queue_free
> caused by the fixing, txq->meta and txq->cmd in error handling code
> of il_tx_queue_init are assigned null values. 
> Otherwise, a double free will occur.
> 
> This patch has been tested in real device, and it actually fixes the bug.
> Thanks Stanislaw for his suggestion.
> 
> Signed-off-by: Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org>

Acked-by: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
