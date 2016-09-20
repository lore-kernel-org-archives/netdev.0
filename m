From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: UBSAN reports issue in ip_idents_reserve
Date: Tue, 20 Sep 2016 18:25:25 +0200
Message-ID: <20160920162525.GM1843@nanopsycho.orion>
References: <20160920120000.GI1843@nanopsycho.orion>
 <1474378115.23058.2.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160920133915.GJ1843@nanopsycho.orion>
 <1474380711.23058.8.camel@edumazet-glaptop3.roam.corp.google.com>
 <1474385116.23058.23.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:37728 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751643AbcITQZ2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 12:25:28 -0400
Received: by mail-wm0-f41.google.com with SMTP id b130so43952667wmc.0
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 09:25:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1474385116.23058.23.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Sep 20, 2016 at 05:25:16PM CEST, eric.dumazet@gmail.com wrote:
>On Tue, 2016-09-20 at 07:11 -0700, Eric Dumazet wrote:
>> On Tue, 2016-09-20 at 15:39 +0200, Jiri Pirko wrote:
>> 
>> > I see. So how to silent the warning?
>> > 
>> 
>> We can replace the atomic_add_return() and use a loop around
>> atomic_read() and atomic_cmpxhg()
>> 
>> This would change the nice property of x86 xadd into a loop.
>> 
>> Or we also could fallback to random generation if the atomic_cmpxchg()
>> fails.
>> 
>> I'll provide a patch, thanks.
>> 

I'm going to test your patch now.

>
>I looks at other places, I am surprised you do not see other UBSAN
>issues in networking :)

Not yet :)

>
>netdev_refcnt_read() can potentially gives errors as well.
>
>
>
