From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Wed, 21 Sep 2016 00:44:16 +0200
Message-ID: <20160920224416.GF3291@pox.localdomain>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
 <1474408824-418864-2-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com,
        tariqt@mellanox.com, bblanco@plumgrid.com,
        alexei.starovoitov@gmail.com, eric.dumazet@gmail.com,
        brouer@redhat.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:37833 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751783AbcITWoT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 18:44:19 -0400
Received: by mail-wm0-f51.google.com with SMTP id b130so60245055wmc.0
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 15:44:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1474408824-418864-2-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/20/16 at 03:00pm, Tom Herbert wrote:
> +static inline int __xdp_hook_run(struct list_head *list_head,
> +				 struct xdp_buff *xdp)
> +{
> +	struct xdp_hook_ops *elem;
> +	int ret = XDP_PASS;
> +
> +	list_for_each_entry(elem, list_head, list) {
> +		ret = elem->hook(elem->priv, xdp);
> +		if (ret != XDP_PASS)
> +			break;
> +	}

Walking over a linear list? Really? :-) I thought this was supposed
to be fast, no compromises made.
