From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH V2 00/22] Broadcom RoCE Driver (bnxt_re)
Date: Mon, 12 Dec 2016 22:41:59 -0800
Message-ID: <CACKFLinhXAeVNZNP10XfKmr3h3tLdebF06yO7wraYeLLsKBqqQ@mail.gmail.com>
References: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com>
 <9cf03e2b-a16d-19ec-a8ce-14f24272bf6a@redhat.com> <CA+sbYW2fF01N5ZQfaH6Uj7Q63SHwdo1gEwR=eoB6vB1ktQaiag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: jtoppins@redhat.com, Doug Ledford <dledford@redhat.com>,
        linux-rdma@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: Selvin Xavier <selvin.xavier@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:33110 "EHLO
        mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752359AbcLMGmA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 01:42:00 -0500
Received: by mail-oi0-f48.google.com with SMTP id w63so113614471oiw.0
        for <netdev@vger.kernel.org>; Mon, 12 Dec 2016 22:42:00 -0800 (PST)
In-Reply-To: <CA+sbYW2fF01N5ZQfaH6Uj7Q63SHwdo1gEwR=eoB6vB1ktQaiag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 12, 2016 at 8:52 PM, Selvin Xavier
<selvin.xavier@broadcom.com> wrote:

>>   CHECK   drivers/infiniband/hw/bnxtre/bnxt_qplib_rcfw.c
>>   CHECK   drivers/infiniband/hw/bnxtre/bnxt_qplib_sp.c
>>   CHECK   drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.c
>> drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.c:1015:22: warning: context
>> imbalance in 'bnxt_qplib_lock_cqs' - wrong count at exit
>> drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.c:1030:28: warning: context
>> imbalance in 'bnxt_qplib_unlock_cqs' - unexpected unlock
> The above two are false positives, since locking and unlocking are
> handled in two separate functions. This is a wrapper to lock/unlock
> both SQ and RQ CQ locks. Functionally it is ok  since
> bnxt_qplib_unlock_cqs is called just after the critical section and
> both locks are freed in order. I think we can ignore this warning.
>
>
You can use __releases() and __acquires() macros to denote these cases
for sparse.
