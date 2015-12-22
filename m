From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v2 2/2] ss: support closing inet sockets via
 SOCK_DESTROY.
Date: Mon, 21 Dec 2015 21:42:22 -0800
Message-ID: <20151221214222.5ee87383@xeon-e3>
References: <1450358538-134898-1-git-send-email-lorenzo@google.com>
	<1450358538-134898-2-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	zenczykowski@gmail.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34992 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457AbbLVFmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 00:42:15 -0500
Received: by mail-pf0-f170.google.com with SMTP id 78so27772703pfw.2
        for <netdev@vger.kernel.org>; Mon, 21 Dec 2015 21:42:15 -0800 (PST)
In-Reply-To: <1450358538-134898-2-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Dec 2015 22:22:18 +0900
Lorenzo Colitti <lorenzo@google.com> wrote:

> diff --git a/misc/ss.c b/misc/ss.c
> index 0dab32c..be70c41 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -160,6 +160,9 @@ struct filter
>  	int states;
>  	int families;
>  	struct ssfilter *f;
> +	struct {
> +		__u8 kill:1;
> +	} action;
>  };
>  
>  stati

Please just make it a boolean or integer, not a structure wrapped around a bit field.
If you need to extend in the future then change it then. Please don't write code
based on speculative future additions.
