From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] codel: add forgotten inline to functions in header file
Date: Thu, 11 Feb 2016 06:30:38 -0800
Message-ID: <1455201038.19473.12.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1455199701-25767-1-git-send-email-emmanuel.grumbach@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireles@vger.kernel.org
To: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:38494 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981AbcBKOak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 09:30:40 -0500
In-Reply-To: <1455199701-25767-1-git-send-email-emmanuel.grumbach@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-02-11 at 16:08 +0200, Emmanuel Grumbach wrote:
> Signed-off-by: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
> ---

> -static bool codel_should_drop(const struct sk_buff *skb,
> -			      struct Qdisc *sch,
> -			      struct codel_vars *vars,
> -			      struct codel_params *params,
> -			      struct codel_stats *stats,
> -			      codel_time_t now)
> +static inline bool codel_should_drop(const struct sk_buff *skb,
> +				     struct Qdisc *sch,
> +				     struct codel_vars *vars,
> +				     struct codel_params *params,
> +				     struct codel_stats *stats,
> +				     codel_time_t now)


The lack of inline was done on purpose.

This include file is kind of special, being included by codel and
fq_codel.

Hint : we do not want to force the compiler to inline
codel_should_drop() (or any other function).


See this file as if it was a .c really.
