From: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH V5 for-next 16/21] RDMA/bnxt_re: Support poll_cq verb
Date: Mon, 13 Feb 2017 10:47:10 +0530
Message-ID: <CA+sbYW36txPueFBWFOWigHu_XmnTPY+-Vdu5MmGeOQ7uFjrWag@mail.gmail.com>
References: <1486725593-9872-1-git-send-email-selvin.xavier@broadcom.com>
 <1486725593-9872-17-git-send-email-selvin.xavier@broadcom.com> <20170212143051.GD14015@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Eddie Wai <eddie.wai-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Devesh Sharma <devesh.sharma-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Somnath Kotur <somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Sriharsha Basavapatna <sriharsha.basavapatna-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170212143051.GD14015-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 12, 2017 at 8:00 PM, Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
>> +static u8 __rc_to_ib_wc_status(u8 qstatus)
>> +{
>> +     switch (qstatus) {
>> +     case CQ_RES_RC_STATUS_OK:
>> +             return IB_WC_SUCCESS;
>> +     case CQ_RES_RC_STATUS_LOCAL_ACCESS_ERROR:
>> +             return IB_WC_LOC_ACCESS_ERR;
>> +     case CQ_RES_RC_STATUS_LOCAL_LENGTH_ERR:
>> +             return IB_WC_LOC_LEN_ERR;
>> +     case CQ_RES_RC_STATUS_LOCAL_PROTECTION_ERR:
>> +             return IB_WC_LOC_PROT_ERR;
>> +     case CQ_RES_RC_STATUS_LOCAL_QP_OPERATION_ERR:
>> +             return IB_WC_LOC_QP_OP_ERR;
>> +     case CQ_RES_RC_STATUS_MEMORY_MGT_OPERATION_ERR:
>> +             return IB_WC_GENERAL_ERR;
>> +     case CQ_RES_RC_STATUS_REMOTE_INVALID_REQUEST_ERR:
>> +             return IB_WC_REM_INV_REQ_ERR;
>> +     case CQ_RES_RC_STATUS_WORK_REQUEST_FLUSHED_ERR:
>> +             return IB_WC_WR_FLUSH_ERR;
>> +     case CQ_RES_RC_STATUS_HW_FLUSH_ERR:
>> +             return IB_WC_WR_FLUSH_ERR;
>> +     default:
>> +             return IB_WC_GENERAL_ERR;
>> +     }
>> +}
>> +
>
> Why don't you use these defines directly?

CQ_RES* values are returned by the HW and these values are
different from the corresponding IB_WC status values.   say,
CQ_RES_RC_STATUS_HW_FLUSH_ERR is 8 where as
IB_WC_WR_FLUSH_ERR is 5.
So we thought it is better to map these values in a function rather
than having a switch/case in the calling function.

Let me know if you meant something different in your query.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
