From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/2] net: diag: allow socket bytecode filters to
 match socket marks
Date: Tue, 23 Aug 2016 12:54:41 -0600
Message-ID: <3c28e5ac-7163-7645-670d-51c718b66f6a@cumulusnetworks.com>
References: <1471975571-26612-1-git-send-email-lorenzo@google.com>
 <1471975571-26612-2-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, davem@davemloft.net
To: Lorenzo Colitti <lorenzo@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34160 "EHLO
        mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752389AbcHWTBi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 15:01:38 -0400
Received: by mail-pa0-f52.google.com with SMTP id fi15so50751775pac.1
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 12:01:23 -0700 (PDT)
In-Reply-To: <1471975571-26612-2-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/23/16 12:06 PM, Lorenzo Colitti wrote:
> @@ -713,10 +728,11 @@ static bool valid_markcond(const struct inet_diag_bc_op *op, int len,
>  	return len >= *min_len;
>  }
>  
> -static int inet_diag_bc_audit(struct nlattr *attr)
> +static int inet_diag_bc_audit(struct nlattr *attr, const struct sk_buff *skb)
>  {
>  	const void *bytecode, *bc;
>  	int bytecode_len, len;
> +	bool net_admin = netlink_net_capable(skb, CAP_NET_ADMIN);
>  
>  	if (!attr || nla_len(attr) < sizeof(struct inet_diag_bc_op))
>  		return -EINVAL;

The net_admin arg should be added as the first local to maintain preference for reverse xmas tree order.
