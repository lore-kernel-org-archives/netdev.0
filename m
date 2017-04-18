From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: question about size of sk_buff and skb_shared_info
Date: Tue, 18 Apr 2017 12:00:21 -0700
Message-ID: <1492542021.10587.137.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CABGNecyP8tpBtbOPL_4fyhqnkTYEa80sHCuDrUJdm9gxihFX6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Code Soldier1 <codesoldier1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33075 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750710AbdDRTAX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 15:00:23 -0400
Received: by mail-pf0-f179.google.com with SMTP id a188so897985pfa.0
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 12:00:23 -0700 (PDT)
In-Reply-To: <CABGNecyP8tpBtbOPL_4fyhqnkTYEa80sHCuDrUJdm9gxihFX6w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-18 at 10:34 -0700, Code Soldier1 wrote:
> Hi Folks,
> 
> I am sure there is a reason for the current sizes of these structures,
> However the reason is not obvious to me. So please help me understand.
> 
> Currently the size of sk_buff on an x86_64 system is 232 bytes -- Why
> is that. I expected it to be a multiple of 32/64 as they are the most
> common cache lines. Since the alignment calculation will align the
> structure with the hw cache line, it seems like we might be wasting
> space ?
> 
> skb_shared_info on the other hand is perfectly aligned with a size of 320 bytes.
> 
> Thanks,
> 

The alignment is there.
Look at skb_init() code, using SLAB_HWCACHE_ALIGN
