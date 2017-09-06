From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next RFC 2/2] tun: enable napi_gro_frags() for
 TUN/TAP driver
Date: Wed, 06 Sep 2017 11:01:35 -0700
Message-ID: <1504720895.15310.69.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170905223551.27925-1-ppenkov@google.com>
         <20170905223551.27925-3-ppenkov@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Willem de Bruijn <willemb@google.com>, davem@davemloft.net,
        ppenkov@stanford.edu
To: Petar Penkov <ppenkov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34693 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750980AbdIFSBi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 14:01:38 -0400
Received: by mail-pf0-f194.google.com with SMTP id y68so3372975pfd.1
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 11:01:37 -0700 (PDT)
In-Reply-To: <20170905223551.27925-3-ppenkov@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-09-05 at 15:35 -0700, Petar Penkov wrote:
> Add a TUN/TAP receive mode that exercises the napi_gro_frags()
> interface. This mode is available only in TAP mode, as the interface
> expects packets with Ethernet headers.
> 


Hi Petar, thanks a lot for this work.

I must confess I have to retract one feedback I gave while reviewing
your patches.


> +		local_bh_disable();
> +		data = napi_alloc_frag(fragsz);
> +		local_bh_enable();
> +		if (!data) {
> +			err = -ENOMEM;
> +			goto free;
> +		}
> +
> +		page = virt_to_page(data);
> +		offset = offset_in_page(data);

These two lines above indeed trigger too many problems in the kernel.
(Like the one you tried to cover here
https://patchwork.kernel.org/patch/9927927/ )

Please use for your next submission the code you originally had :

	page = virt_to_head_page(data);
	offset = data - page_address(page);


Thanks !
