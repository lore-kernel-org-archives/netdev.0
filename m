From: Serhey Popovych <serhe.popovych@gmail.com>
Subject: Re: [PATCH 2/3] dev: Avoid infinite loop on network device index
 exhaustion
Date: Fri, 16 Jun 2017 19:32:53 +0300
Message-ID: <84cff1ae-94f8-dfbe-fbea-3bd9cbc8663a@gmail.com>
References: <cover.1497621810.git.serhe.popovych@gmail.com>
 <a6cc35519e46dc988a983f4b167ccd420b42a0fa.1497621810.git.serhe.popovych@gmail.com>
 <20170616091659.3361b5d0@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33001 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750792AbdFPQc4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 12:32:56 -0400
Received: by mail-wm0-f68.google.com with SMTP id f90so5971117wmh.0
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 09:32:56 -0700 (PDT)
In-Reply-To: <20170616091659.3361b5d0@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Fri, 16 Jun 2017 17:23:52 +0300
> Serhey Popovych <serhe.popovych@gmail.com> wrote:
> 
>> If network device indexes exhaust in namespace dev_new_index()
>> can loop indefinitely since there is no condition to exit
>> except case where free index is found.
>>
>> Since all it's caller hold RTNL mutex this may completely
>> lock down network subsystem configuration operations.
>>
>> Instead of retrying with ifindex == 1 (LOOPBACK_IFINDEX)
>> in dev_new_index() we should fail and return invalid
>> index value (0).
>>
>> Adjust callers to correctly handle error case of dev_new_index().
>>
>> Signed-off-by: Serhey Popovych <serhe.popovych@gmail.com>
>  
> This breaks existing semantics.
> 
> Today on Linux the ifindex allocator intentionally wraps around back to 1.
> This is to handle the case of long running system with things like VPN's
> that create and destroy lots of devices.
> 
Ok, got it. Maybe we can change allocation mechanism?

That what actually I did.
What do you think?

I will show POC patch doing this.

-- 
Thanks, Serhey
