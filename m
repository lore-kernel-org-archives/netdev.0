From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] team: use a larger struct for mac address
Date: Thu, 20 Jul 2017 16:42:38 -0700
Message-ID: <CAM_iQpVEDq2iTURYYvUgr1vOgmZtRJ8-brD0gvZvBRw+OWjUKg@mail.gmail.com>
References: <20170720230646.30364-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Andrey Konovalov <andreyknvl@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33110 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964894AbdGTXm7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 19:42:59 -0400
Received: by mail-wm0-f68.google.com with SMTP id 65so5234064wmf.0
        for <netdev@vger.kernel.org>; Thu, 20 Jul 2017 16:42:59 -0700 (PDT)
In-Reply-To: <20170720230646.30364-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 20, 2017 at 4:06 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> IPv6 tunnels use sizeof(struct in6_addr) as dev->addr_len,
> but in many places especially bonding, we use struct sockaddr
> to copy and set mac addr, this could lead to stack out-of-bounds
> access.
>
> Fix it by using a larger address storage like bonding.
>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Cc: Jiri Pirko <jiri@resnulli.us>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

For DaveM:

This patch depends on my previous patch "net: check mac
address length for dev_set_mac_address()", otherwise
dev_set_mac_address() doesn't accept struct sockaddr_storage.

I can add a cast there if you feel this is easier for backport, but
I think we need to backport both.

Sorry for any confusion.
