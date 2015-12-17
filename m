From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [iproute PATCH v2 1/2] libnetlink: add a variant of
 rtnl_send_check that consumes ACKs
Date: Thu, 17 Dec 2015 08:07:22 -0800
Message-ID: <1450368442.8474.106.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1450358538-134898-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	zenczykowski@gmail.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33759 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966354AbbLQQHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 11:07:24 -0500
Received: by mail-pf0-f172.google.com with SMTP id n128so14799828pfn.0
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2015 08:07:24 -0800 (PST)
In-Reply-To: <1450358538-134898-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-12-17 at 22:22 +0900, Lorenzo Colitti wrote:
> The new variant is identical to rtnl_send_check, except it also
> consumes the kernel response instead of using MSG_PEEK. This is
> useful for callers that send simple commands that never cause a
> response but only ACKs, and that expect to receive and deal
> with errors without printing them to stderr like rtnl_talk does.

> +inline int rtnl_send_check(struct rtnl_handle *rth, const void *buf, int len)
> +{
> +	return rtnl_send_check_ack(rth, buf, len, 0);
> +}

Please remove this inline attribute.
