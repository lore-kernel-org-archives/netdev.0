From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 7/9] skge: use napi_complete_done()
Date: Sat, 4 Feb 2017 13:44:18 -0800
Message-ID: <20170204134418.6974d7ad@xeon-e3>
References: <20170204182038.3752-1-edumazet@google.com>
        <20170204182038.3752-8-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:33139 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750944AbdBDVoV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 16:44:21 -0500
Received: by mail-pg0-f42.google.com with SMTP id 204so16706560pge.0
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 13:44:21 -0800 (PST)
In-Reply-To: <20170204182038.3752-8-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  4 Feb 2017 10:20:36 -0800
Eric Dumazet <edumazet@google.com> wrote:

>  
> -static int skge_poll(struct napi_struct *napi, int to_do)
> +static int skge_poll(struct napi_struct *napi, int budget)

Ok, but renaming parameter is not really necessary.

> -	if (work_done < to_do) {
> +	if ((work_done < budget) && napi_complete_done(napi, work_done)) {
>  		unsigned long flags;

Parenthesis around work_done < budget are unnecessary.

Other than that it looks fine.
