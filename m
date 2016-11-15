From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: linux-next: net->netns_ids is used after calling idr_destroy for it
Date: Tue, 15 Nov 2016 10:04:32 -0800
Message-ID: <CAM_iQpUQOCsVkaRPU3OkmNvyOLDtmRRK1G3uzvi9URSVEbapJQ@mail.gmail.com>
References: <CANaxB-x7FgxpAwpa-RgOvUptrCRUmAE6NFm3As+LuXUE=fHJyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Andrei Vagin <avagin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.161.176]:34991 "EHLO
        mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752236AbcKOSE4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 13:04:56 -0500
Received: by mail-yw0-f176.google.com with SMTP id i145so107227943ywg.2
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 10:04:55 -0800 (PST)
In-Reply-To: <CANaxB-x7FgxpAwpa-RgOvUptrCRUmAE6NFm3As+LuXUE=fHJyA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 14, 2016 at 10:23 PM, Andrei Vagin <avagin@gmail.com> wrote:
> Hi Nicolas,
>
> cleanup_net() calls idr_destroy(net->netns_ids) for network namespaces
> and then it calls unregister_netdevice_many() which calls
> idr_alloc(net0>netns_ids). It looks wrong, doesn't it?
>

netns id is designed to allocate lazily, but yeah it makes no sense
to allocate id for the netns being destroyed, not to mention idr is freed.

I will send a patch.
