From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: drivers/net/chelsio/my3126.c: inconsequent NULL checking
Date: Thu, 7 Dec 2006 14:22:51 +0100
Message-ID: <9a8748490612070522v2a4f8446l9833758526c3a1ba@mail.gmail.com>
References: <20061207113452.GD8963@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Stephen Hemminger" <shemminger@osdl.org>, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.238]:19943 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1032183AbWLGNWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 08:22:52 -0500
Received: by wx-out-0506.google.com with SMTP id h27so529419wxd
        for <netdev@vger.kernel.org>; Thu, 07 Dec 2006 05:22:51 -0800 (PST)
To: "Adrian Bunk" <bunk@stusta.de>
In-Reply-To: <20061207113452.GD8963@stusta.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/12/06, Adrian Bunk <bunk@stusta.de> wrote:
> The Coverity checker spotted the following inconsequent NULL checking
> introduced by commit f1d3d38af75789f1b82969b83b69cab540609789:
>
> <--  snip  -->
>
> ...
> static struct cphy *my3126_phy_create(adapter_t *adapter,
>                         int phy_addr, struct mdio_ops *mdio_ops)
> {
>         struct cphy *cphy = kzalloc(sizeof (*cphy), GFP_KERNEL);
>
>         if (cphy)
>                 cphy_init(cphy, adapter, phy_addr, &my3126_ops, mdio_ops);
>
>         INIT_WORK(&cphy->phy_update, my3216_poll, cphy);
>         cphy->bmsr = 0;
>
>         return (cphy);
> }
> ...
>
> <--  snip  -->
>
> It doesn't make sense to first check whether "cphy" is NULL and
> dereference it unconditionally later.
>

How about simply changing
         if (cphy)
                 cphy_init(cphy, adapter, phy_addr, &my3126_ops, mdio_ops);
into
         if (!cphy)
                 return NULL;

callers need to be able to handle that ofcourse, but I haven't checked that yet.

-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
