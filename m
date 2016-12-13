From: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH V2 00/22] Broadcom RoCE Driver (bnxt_re)
Date: Tue, 13 Dec 2016 10:22:52 +0530
Message-ID: <CA+sbYW2fF01N5ZQfaH6Uj7Q63SHwdo1gEwR=eoB6vB1ktQaiag@mail.gmail.com>
References: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com> <9cf03e2b-a16d-19ec-a8ce-14f24272bf6a@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jtoppins-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <9cf03e2b-a16d-19ec-a8ce-14f24272bf6a-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 12, 2016 at 10:24 PM, Jonathan Toppins <jtoppins-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> CHECK   drivers/infiniband/hw/bnxtre/bnxt_re_debugfs.c
>   CHECK   drivers/infiniband/hw/bnxtre/bnxt_qplib_res.c
> drivers/infiniband/hw/bnxtre/bnxt_qplib_res.c:729:6: warning: symbol
> 'bnxt_qplib_cleanup_pkey_tbl' was not declared. Should it be static?
I will remove this warning in v3 patch set.

>   CHECK   drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.c
>   CHECK   drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.c
>   CHECK   drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.c
> drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.c:1015:22: warning: context
> imbalance in 'bnxt_qplib_lock_cqs' - wrong count at exit
> drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.c:1030:28: warning: context
> imbalance in 'bnxt_qplib_unlock_cqs' - unexpected unlock
The above two are false positives, since locking and unlocking are
handled in two separate functions. This is a wrapper to lock/unlock
both SQ and RQ CQ locks. Functionally it is ok  since
bnxt_qplib_unlock_cqs is called just after the critical section and
both locks are freed in order. I think we can ignore this warning.


>   MODPOST 2 modules
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
