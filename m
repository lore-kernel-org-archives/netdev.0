From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 net-next 06/12] qed: Add LL2 slowpath handling
Date: Tue, 03 Oct 2017 10:17:12 -0700 (PDT)
Message-ID: <20171003.101712.715882117516958741.davem@davemloft.net>
References: <1507020902-4952-1-git-send-email-Michal.Kalderon@cavium.com>
        <1507020902-4952-7-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
To: Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1507020902-4952-7-git-send-email-Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Date: Tue, 3 Oct 2017 11:54:56 +0300

> @@ -423,6 +423,41 @@ static void qed_ll2_rxq_parse_reg(struct qed_hwfn *p_hwfn,
>  }
>  
>  static int
> +qed_ll2_handle_slowpath(struct qed_hwfn *p_hwfn,
> +			struct qed_ll2_info *p_ll2_conn,
> +			union core_rx_cqe_union *p_cqe,
> +			unsigned long *p_lock_flags)
> +{
 ...
> +	spin_unlock_irqrestore(&p_rx->lock, *p_lock_flags);
> +

You can't drop this lock.

Another thread can enter the loop of our caller and process RX queue
entries, then we would return from here and try to process the same
entries again.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
