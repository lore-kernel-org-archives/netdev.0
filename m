From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next 3/4] flowcache: Fixup flow cache part in xfrm policy
Date: Mon, 13 Jan 2014 11:42:47 -0800
Message-ID: <CAHA+R7NpPN0pGu-S568CdtvkDRYmNei40Qus5SAK935d6vuTDw@mail.gmail.com>
References: <1389599348-5214-1-git-send-email-fan.du@windriver.com>
	<1389599348-5214-4-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: steffen.klassert@secunet.com, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:59782 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752527AbaAMTms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 14:42:48 -0500
Received: by mail-la0-f42.google.com with SMTP id n7so732788lam.15
        for <netdev@vger.kernel.org>; Mon, 13 Jan 2014 11:42:47 -0800 (PST)
In-Reply-To: <1389599348-5214-4-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 12, 2014 at 11:49 PM, Fan Du <fan.du@windriver.com> wrote:
>  void xfrm_garbage_collect(struct net *net)
>  {
> -       flow_cache_flush();
> +       flow_cache_flush(net);
>         __xfrm_garbage_collect(net);
>  }
>  EXPORT_SYMBOL(xfrm_garbage_collect);
>
>  static void xfrm_garbage_collect_deferred(struct net *net)
>  {
> -       flow_cache_flush_deferred();
> +       flow_cache_flush_deferred(net);
>         __xfrm_garbage_collect(net);
>  }
>

You changed the prototypes of flow_cache_flush*() in the previous
patch, so, here you break bisect. They have to be in one commit.
