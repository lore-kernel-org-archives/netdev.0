From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: Crash after reloading driver if network hangs
Date: Mon, 29 Jan 2007 08:56:06 +0100
Message-ID: <20070129075606.GA10598@electric-eye.fr.zoreil.com>
References: <20070128180221.GB2285@strauss.suse.de> <20070128190448.GA23060@electric-eye.fr.zoreil.com> <20070128195656.GA6013@strauss.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bernhard Walle <bwalle@suse.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:36314 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933176AbXA2H4i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 02:56:38 -0500
Content-Disposition: inline
In-Reply-To: <20070128195656.GA6013@strauss.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bernhard Walle <bwalle@suse.de> :
[...]
> Doesn't compile, I think you mean this?

Yes.

> @@ -1371,10 +1371,9 @@ static inline void rtl8169_request_timer
>                 return;
>  
>         init_timer(timer);
> -       timer->expires = jiffies + RTL8169_PHY_TIMEOUT;
>         timer->data = (unsigned long)(dev);
>         timer->function = rtl8169_phy_timer;
> -       add_timer(timer);
> +       mod_timer(timer, jiffies + RTL8169_PHY_TIMEOUT);
>  }
> 
> But I think _this_ change is unnecessary, ...

add_timer() is not supposed to modify an existing timer whereas mod_timer()
encompasses both and the race exists in both direction as netif_running()
is true as soon as dev_open() starts but way before dev->open() completes.

[...]
> ... but that looks good (better than my patch) and should resolve the issue,
> too. I can't test because it's triggered only if the network hangs and you
> know, the last one isn't reproducable.

There will be something to test in the merge of realtek's stuff #2.

-- 
Ueimor
