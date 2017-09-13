From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: potential read out of bounds in
 sctp_ulpevent_type_enabled()
Date: Wed, 13 Sep 2017 09:25:22 -0700 (PDT)
Message-ID: <20170913.092522.934509429497822082.davem@davemloft.net>
References: <20170913092028.idzvduj7ran4li6b@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com,
        linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51510 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751457AbdIMQZX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 12:25:23 -0400
In-Reply-To: <20170913092028.idzvduj7ran4li6b@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 13 Sep 2017 12:20:28 +0300

> @@ -154,7 +154,11 @@ static inline int sctp_ulpevent_type_enabled(__u16 sn_type,
>  					     struct sctp_event_subscribe *mask)
>  {
>  	char *amask = (char *) mask;
> -	return amask[sn_type - SCTP_SN_TYPE_BASE];
> +	int offset = sn_type - SCTP_SN_TYPE_BASE;

Please use reverse-christmas-tree local variable ordering.

Thank you.
