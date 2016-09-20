From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UBSAN reports issue in ip_idents_reserve
Date: Tue, 20 Sep 2016 07:11:51 -0700
Message-ID: <1474380711.23058.8.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160920120000.GI1843@nanopsycho.orion>
         <1474378115.23058.2.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160920133915.GJ1843@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34884 "EHLO
        mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751443AbcITOLz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 10:11:55 -0400
Received: by mail-pa0-f43.google.com with SMTP id oz2so7547942pac.2
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 07:11:55 -0700 (PDT)
In-Reply-To: <20160920133915.GJ1843@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-09-20 at 15:39 +0200, Jiri Pirko wrote:

> I see. So how to silent the warning?
> 

We can replace the atomic_add_return() and use a loop around
atomic_read() and atomic_cmpxhg()

This would change the nice property of x86 xadd into a loop.

Or we also could fallback to random generation if the atomic_cmpxchg()
fails.

I'll provide a patch, thanks.
