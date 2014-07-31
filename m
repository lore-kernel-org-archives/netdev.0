From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 1/5] net-timestamp: extend SCM_TIMESTAMPING
 ancillary data struct
Date: Thu, 31 Jul 2014 13:37:11 -0700 (PDT)
Message-ID: <20140731.133711.750711941438180832.davem@davemloft.net>
References: <1406735328-7520-1-git-send-email-willemb@google.com>
	<1406735328-7520-2-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	richardcochran@gmail.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50677 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752245AbaGaUhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 16:37:12 -0400
In-Reply-To: <1406735328-7520-2-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Wed, 30 Jul 2014 11:48:44 -0400

> Applications that request kernel tx timestamps with SO_TIMESTAMPING
> read timestamps as recvmsg() ancillary data. The response is defined
> implicitly as timespec[3].
> 
> 1) define struct scm_timestamping explicitly and
> 
> 2) add support for new tstamp types. On tx, scm_timestamping always
>    accompanies a sock_extended_err. Define previously unused field
>    ee_info to signal the type of ts[0]. Introduce SCM_TSTAMP_SND.
> 
> The reception path is not modified. On rx, no struct similar to
> sock_extended_err is passed along with SCM_TIMESTAMPING.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>
 ...
> +/* type of ts[0], passed in ee_info */
> +enum {
> +	SCM_TSTAMP_SND = 1,	/* driver passed skb to NIC */
> +};
 ...
> @@ -3521,6 +3521,7 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
>  	memset(serr, 0, sizeof(*serr));
>  	serr->ee.ee_errno = ENOMSG;
>  	serr->ee.ee_origin = SO_EE_ORIGIN_TIMESTAMPING;
> +	serr->ee.ee_info = hwtstamps ? 0 : SCM_TSTAMP_SND;
>  
>  	err = sock_queue_err_skb(sk, skb);
>  

Up until now we've placed the value zero in the ee_info field, do you have
a strong reason to not define SCM_TSTAMP_SND to zero as well?

Unless you have a compelling reason to do otherwise, we should use zero.
