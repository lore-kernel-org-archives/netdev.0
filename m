From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fec: Fixed panic problem with non-tso
Date: Tue, 17 Jan 2017 20:21:23 -0800
Message-ID: <1484713283.13165.89.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170117074820.5106-1-ashiduka@jp.fujitsu.com>
         <AM4PR0401MB2260E5BE096D7B86EDF4F04FFF7C0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
         <337A096076BEF646A1F21E1AD855580E3AC8F71A@g01jpexmbkw23>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andy Duan <fugang.duan@nxp.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Ashizuka, Yuusuke" <ashiduka@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33606 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751132AbdARE2M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 23:28:12 -0500
Received: by mail-pf0-f195.google.com with SMTP id e4so206069pfg.0
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 20:28:11 -0800 (PST)
In-Reply-To: <337A096076BEF646A1F21E1AD855580E3AC8F71A@g01jpexmbkw23>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-01-18 at 03:12 +0000, Ashizuka, Yuusuke wrote:

> indeed.
> 
> In the case of TSO with i.MX6 system (highmem enabled) with 2GB memory,
> "this_frag->page.p" did not become highmem area.
> (We confirmed by transferring about 100MB of files)
> 
> However, in the case of non-tso on an i.MX6 system with 2GB of memory,
> "this_frag->page.p" may become a highmem area.
> (Occurred with approximately 2MB of file transfer)
> 
> For non-tso only, I do not know the reason why "this_frag-> page.p" 
> in this driver shows highmem area.

This worries me, since this driver does not set NETIF_F_HIGHDMA in its
features.

No packet should be given to this driver with a highmem fragment

Check is done in illegal_highdma() in net/core/dev.c
