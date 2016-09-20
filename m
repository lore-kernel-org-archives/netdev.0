From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UBSAN reports issue in ip_idents_reserve
Date: Tue, 20 Sep 2016 08:25:16 -0700
Message-ID: <1474385116.23058.23.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160920120000.GI1843@nanopsycho.orion>
         <1474378115.23058.2.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160920133915.GJ1843@nanopsycho.orion>
         <1474380711.23058.8.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34134 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754246AbcITPZT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 11:25:19 -0400
Received: by mail-pf0-f177.google.com with SMTP id p64so8483425pfb.1
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 08:25:18 -0700 (PDT)
In-Reply-To: <1474380711.23058.8.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-09-20 at 07:11 -0700, Eric Dumazet wrote:
> On Tue, 2016-09-20 at 15:39 +0200, Jiri Pirko wrote:
> 
> > I see. So how to silent the warning?
> > 
> 
> We can replace the atomic_add_return() and use a loop around
> atomic_read() and atomic_cmpxhg()
> 
> This would change the nice property of x86 xadd into a loop.
> 
> Or we also could fallback to random generation if the atomic_cmpxchg()
> fails.
> 
> I'll provide a patch, thanks.
> 

I looks at other places, I am surprised you do not see other UBSAN
issues in networking :)

netdev_refcnt_read() can potentially gives errors as well.
