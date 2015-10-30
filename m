From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net PATCH 3/3] ixgbe: Fix handling of napi budget when multiple
 queues are enabled per vector
Date: Fri, 30 Oct 2015 09:11:07 -0700
Message-ID: <5633969B.1050401@gmail.com>
References: <20150922213002.2774.37924.stgit@ahduyck-vm-fedora22>
 <20150922213541.2774.70538.stgit@ahduyck-vm-fedora22>
 <CAJ75kXZx9YoD4_k7yb2aEomhxceG96D-twPqYz_-9QmY-2MXvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	jeffrey.t.kirsher@intel.com
To: William Dauchy <wdauchy@gmail.com>,
	Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:32963 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842AbbJ3QLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 12:11:09 -0400
Received: by padhy1 with SMTP id hy1so72356089pad.0
        for <netdev@vger.kernel.org>; Fri, 30 Oct 2015 09:11:08 -0700 (PDT)
In-Reply-To: <CAJ75kXZx9YoD4_k7yb2aEomhxceG96D-twPqYz_-9QmY-2MXvw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/30/2015 07:55 AM, William Dauchy wrote:
> Hi Alexander,
>
> On Tue, Sep 22, 2015 at 11:35 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
>> This patch corrects an issue in which the polling routine would increase
>> the budget for Rx to at least 1 per queue if multiple queues were present.
>> This would result in Rx packets being processed when the budget was 0 which
>> is meant to indicate that no Rx can be handled.
> We may logically have the same issue with VF, right?
>
>  From 4521374ae746543a925982d59a8ba73b6aaee59c Mon Sep 17 00:00:00 2001
> From: William Dauchy <william@gandi.net>
> Date: Fri, 30 Oct 2015 15:48:43 +0100
> Subject: [PATCH] ixgbevf: Fix handling of napi budget when multiple queues are
>   enabled per vector
>
> This is the same patch as for ixgbe but applied differently according to
> busy polling
>
> Signed-off-by: William Dauchy <william@gandi.net>
> ---
>   drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 2 ++
>   1 file changed, 2 insertions(+)
>
> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> index 149a0b4..ff6e21d 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> @@ -1014,6 +1014,8 @@ static int ixgbevf_poll(struct napi_struct
> *napi, int budget)
>    ixgbevf_for_each_ring(ring, q_vector->tx)
>    clean_complete &= ixgbevf_clean_tx_irq(q_vector, ring);
>
> + if (budget <= 0)
> + return budget;
>   #ifdef CONFIG_NET_RX_BUSY_POLL
>    if (!ixgbevf_qv_lock_napi(q_vector))
>    return budget;

Yes the same issue applies to ixgbevf, but it looks like your patch was 
mangled by your mail client.  Can you please resubmit with the white 
spaces fixed?

- Alex
