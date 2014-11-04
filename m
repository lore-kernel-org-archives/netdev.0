From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 02/13] net_sched: introduce qdisc_peek() helper function
Date: Tue, 4 Nov 2014 10:45:15 -0800
Message-ID: <20141104104515.2e6433c6@uryu.home.lan>
References: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
	<1415123796-8093-3-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:54399 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751084AbaKDStU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 13:49:20 -0500
Received: by mail-pd0-f170.google.com with SMTP id z10so14162156pdj.15
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 10:49:19 -0800 (PST)
In-Reply-To: <1415123796-8093-3-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  4 Nov 2014 09:56:25 -0800
Cong Wang <xiyou.wangcong@gmail.com> wrote:

> +static inline void qdisc_warn_nonwc(void *func, struct Qdisc *qdisc)
> +{
> +	if (!(qdisc->flags & TCQ_F_WARN_NONWC)) {
> +		pr_warn("%pf: %s qdisc %X: is non-work-conserving?\n",
> +			func, qdisc->ops->id, qdisc->handle >> 16);
> +		qdisc->flags |= TCQ_F_WARN_NONWC;
> +	}
> +}
> +

Inilining this and creating N copies of same message is not a step forward.
