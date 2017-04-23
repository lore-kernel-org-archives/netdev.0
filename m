From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v2 net] net: ipv6: regenerate host route if moved to gc
 list
Date: Sun, 23 Apr 2017 08:08:05 -0600
Message-ID: <607a26c5-4cb4-b84b-37a0-b79ea6b9df26@cumulusnetworks.com>
References: <1492879237-31566-1-git-send-email-dsa@cumulusnetworks.com>
 <20170422220041.wha72qa3zuy23hkf@kafai-mba.local>
 <072e9af7-2163-ce53-ce74-a288e0934825@cumulusnetworks.com>
 <20170423022801.t7lw3vuazo2ks6u4@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com, andreyknvl@google.com,
        mmanning@brocade.com
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:34817 "EHLO
        mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1045566AbdDWOIH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 10:08:07 -0400
Received: by mail-oi0-f54.google.com with SMTP id j201so139170842oih.2
        for <netdev@vger.kernel.org>; Sun, 23 Apr 2017 07:08:07 -0700 (PDT)
In-Reply-To: <20170423022801.t7lw3vuazo2ks6u4@kafai-mba.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/22/17 8:28 PM, Martin KaFai Lau wrote:
>> The code path to fixup_permanent_addr is under RTNL, so the if check on
>> ifp->rt and rt6i_ref is ok -- neither can be changed since RTNL is held.
>>
>> Since ifp->rt can be accessed outside of RTNL, the spinlock is needed to
>> change its value.
> Got it. It is to protect the readers which are not under RTNL.
> Many thanks for pointing out what I was missing.  It all makes sense now.
> 
>> Arguably only 'ifp->rt = rt;' needs the spinlock.
> It still seems like the existing 'ifp->rt = rt;' needs protection
> anyway regardless of the rt regeneration change.  It would be nice to
> explain it in the commit log or even better separating it out
> into another patch.

I'll add a comment to the commit log when I send a v3 tomorrow morning.
