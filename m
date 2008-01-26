From: "Alon Bar-Lev" <alon.barlev@gmail.com>
Subject: Re: iproute2 (addr flush) infinite loop when unprivileged users
Date: Sat, 26 Jan 2008 02:22:43 +0200
Message-ID: <9e0cf0bf0801251622w203c515fn80cba5f233bd599d@mail.gmail.com>
References: <9e0cf0bf0801251500u388b9a5dxda92d6d1e3d86233@mail.gmail.com>
	 <20080125161259.0356c990@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:59227 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754206AbYAZAWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 19:22:44 -0500
Received: by ug-out-1314.google.com with SMTP id z38so606813ugc.16
        for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 16:22:43 -0800 (PST)
In-Reply-To: <20080125161259.0356c990@deepthought>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/26/08, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> The issue is that iproute is just blindly sending the deletes and
> not asking for acknowledgment status. Here is a trivial patch to iproute
> to fix that, but the problem is that it means it will slow down bulk removal.
>
> Maybe it should just check the first, or last delete to see if there are
> errors?
>
> diff --git a/ip/iproute.c b/ip/iproute.c
> index 7a885b0..b2ae879 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c

This should also be applied into ip/ipaddress.c, ip/ipneigh.c
Or even make one common function?

I don't quite understand how "fast" is good if not complete... But
anyway... I will be happy to see this fix in next version... Maybe add
--fast argument? :)

Alon.
