From: Chris Leech <cleech-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 22/29] drivers, scsi: convert iscsi_task.refcount from
 atomic_t to refcount_t
Date: Wed, 8 Mar 2017 10:47:40 -0800
Message-ID: <20170308184740.4gueok5csdkt7u62@straylight.hirudinean.org>
References: <1488810076-3754-1-git-send-email-elena.reshetova@intel.com>
 <1488810076-3754-23-git-send-email-elena.reshetova@intel.com>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux1394-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-bcache-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-raid-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devel-tBiZLqfeLfOHmIFyCCdPziST3g8Odh+X@public.gmane.org, linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org,
        linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
        devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, Hans Liljestrand <ishkamiel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, David Windsor <dwindsor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <open-iscsi+bncBCYMVIPVXQMBBVNDQHDAKGQEAINHI4I-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <1488810076-3754-23-git-send-email-elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
List-Post: <https://groups.google.com/group/open-iscsi/post>, <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/open-iscsi
List-Subscribe: <https://groups.google.com/group/open-iscsi/subscribe>, <mailto:open-iscsi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+856124926423+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/open-iscsi/subscribe>
List-Id: netdev.vger.kernel.org

On Mon, Mar 06, 2017 at 04:21:09PM +0200, Elena Reshetova wrote:
> refcount_t type and corresponding API should be
> used instead of atomic_t when the variable is used as
> a reference counter. This allows to avoid accidental
> refcounter overflows that might lead to use-after-free
> situations.
> 
> Signed-off-by: Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Hans Liljestrand <ishkamiel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> Signed-off-by: David Windsor <dwindsor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

This looks OK to me.

Acked-by: Chris Leech <cleech-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

> ---
>  drivers/scsi/libiscsi.c        | 8 ++++----
>  drivers/scsi/qedi/qedi_iscsi.c | 2 +-
>  include/scsi/libiscsi.h        | 3 ++-
>  3 files changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/scsi/libiscsi.c b/drivers/scsi/libiscsi.c
> index 834d121..7eb1d2c 100644
> --- a/drivers/scsi/libiscsi.c
> +++ b/drivers/scsi/libiscsi.c
> @@ -516,13 +516,13 @@ static void iscsi_free_task(struct iscsi_task *task)
>  
>  void __iscsi_get_task(struct iscsi_task *task)
>  {
> -	atomic_inc(&task->refcount);
> +	refcount_inc(&task->refcount);
>  }
>  EXPORT_SYMBOL_GPL(__iscsi_get_task);
>  
>  void __iscsi_put_task(struct iscsi_task *task)
>  {
> -	if (atomic_dec_and_test(&task->refcount))
> +	if (refcount_dec_and_test(&task->refcount))
>  		iscsi_free_task(task);
>  }
>  EXPORT_SYMBOL_GPL(__iscsi_put_task);
> @@ -744,7 +744,7 @@ __iscsi_conn_send_pdu(struct iscsi_conn *conn, struct iscsi_hdr *hdr,
>  	 * released by the lld when it has transmitted the task for
>  	 * pdus we do not expect a response for.
>  	 */
> -	atomic_set(&task->refcount, 1);
> +	refcount_set(&task->refcount, 1);
>  	task->conn = conn;
>  	task->sc = NULL;
>  	INIT_LIST_HEAD(&task->running);
> @@ -1616,7 +1616,7 @@ static inline struct iscsi_task *iscsi_alloc_task(struct iscsi_conn *conn,
>  	sc->SCp.phase = conn->session->age;
>  	sc->SCp.ptr = (char *) task;
>  
> -	atomic_set(&task->refcount, 1);
> +	refcount_set(&task->refcount, 1);
>  	task->state = ISCSI_TASK_PENDING;
>  	task->conn = conn;
>  	task->sc = sc;
> diff --git a/drivers/scsi/qedi/qedi_iscsi.c b/drivers/scsi/qedi/qedi_iscsi.c
> index b9f79d3..3895bd5 100644
> --- a/drivers/scsi/qedi/qedi_iscsi.c
> +++ b/drivers/scsi/qedi/qedi_iscsi.c
> @@ -1372,7 +1372,7 @@ static void qedi_cleanup_task(struct iscsi_task *task)
>  {
>  	if (!task->sc || task->state == ISCSI_TASK_PENDING) {
>  		QEDI_INFO(NULL, QEDI_LOG_IO, "Returning ref_cnt=%d\n",
> -			  atomic_read(&task->refcount));
> +			  refcount_read(&task->refcount));
>  		return;
>  	}
>  
> diff --git a/include/scsi/libiscsi.h b/include/scsi/libiscsi.h
> index b0e275d..24d74b5 100644
> --- a/include/scsi/libiscsi.h
> +++ b/include/scsi/libiscsi.h
> @@ -29,6 +29,7 @@
>  #include <linux/timer.h>
>  #include <linux/workqueue.h>
>  #include <linux/kfifo.h>
> +#include <linux/refcount.h>
>  #include <scsi/iscsi_proto.h>
>  #include <scsi/iscsi_if.h>
>  #include <scsi/scsi_transport_iscsi.h>
> @@ -139,7 +140,7 @@ struct iscsi_task {
>  
>  	/* state set/tested under session->lock */
>  	int			state;
> -	atomic_t		refcount;
> +	refcount_t		refcount;
>  	struct list_head	running;	/* running cmd list */
>  	void			*dd_data;	/* driver/transport data */
>  };
> -- 
> 2.7.4
> 

-- 
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To unsubscribe from this group and stop receiving emails from it, send an email to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
Visit this group at https://groups.google.com/group/open-iscsi.
For more options, visit https://groups.google.com/d/optout.
