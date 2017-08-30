From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 3/6] flow_dissector: Add protocol specific
 flow dissection offload
Date: Tue, 29 Aug 2017 18:00:24 -0700 (PDT)
Message-ID: <20170829.180024.322953630308674415.davem@davemloft.net>
References: <20170829232711.1465-1-tom@quantonium.net>
        <20170829232711.1465-4-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tom@quantonium.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42872 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751297AbdH3BAZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 21:00:25 -0400
In-Reply-To: <20170829232711.1465-4-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@quantonium.net>
Date: Tue, 29 Aug 2017 16:27:08 -0700

> +#define GOTO_BY_RESULT(ret) do {				\
> +	switch (ret) {						\
> +	case FLOW_DISSECT_RET_OUT_GOOD:				\
> +		goto out_good;					\
> +	case FLOW_DISSECT_RET_PROTO_AGAIN:			\
> +		goto proto_again;				\
> +	case FLOW_DISSECT_RET_IPPROTO_AGAIN:			\
> +		goto ip_proto_again;				\
> +	case FLOW_DISSECT_RET_OUT_BAD:				\
> +	default:						\
> +		goto out_bad;					\
> +	}							\
> +} while (0)
> +
> +#define GOTO_OR_CONT_BY_RESULT(ret) do {			\
> +	enum flow_dissect_ret __ret = (ret);			\
> +								\
> +	if (__ret != FLOW_DISSECT_RET_CONTINUE)			\
> +		GOTO_BY_RESULT(__ret);				\
> +} while (0)

Please don't hide major control flow changes inside of a macro.  This
means returns and gotos.

It makes code impossible to audit.

Yes, this applies even if the macro has the word "GOTO" in it :-)
