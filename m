From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: UDP sockets oddities
Date: Fri, 25 Aug 2017 18:17:34 -0700
Message-ID: <ce4af8cc-3de1-a777-967c-a57103994e1d@gmail.com>
References: <3fed7679-0e19-8a0a-eee6-11baa5654fac@gmail.com>
 <1503527210.2499.63.camel@edumazet-glaptop3.roam.corp.google.com>
 <9a9c1c94-4902-2ec9-d216-3f5cfb3044af@gmail.com>
 <1503529476.2499.65.camel@edumazet-glaptop3.roam.corp.google.com>
 <6c88e440-3f36-858d-1a08-bd32a2c66f4e@gmail.com>
 <1503535426.2499.66.camel@edumazet-glaptop3.roam.corp.google.com>
 <4adb4b66-590c-c55a-44aa-27dd409ce14f@gmail.com>
 <3c44d27e-27d9-e9c4-04b3-17c0366e60d9@gmail.com>
 <1503705440.11498.9.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, edumazet@gmail.com, pabeni@redhat.com,
        willemb@google.com, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:34924 "EHLO
        mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751426AbdHZBRj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 21:17:39 -0400
Received: by mail-qk0-f179.google.com with SMTP id p67so6627658qkd.2
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 18:17:38 -0700 (PDT)
In-Reply-To: <1503705440.11498.9.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/25/2017 04:57 PM, Eric Dumazet wrote:
> On Fri, 2017-08-25 at 16:18 -0700, Florian Fainelli wrote:
> 
>> Eric, are there areas of the stack where we are allowed to drop packets,
>> not propagate that back to write(2) and also not increment any counter
>> either, or maybe I am not looking where I should...
> 
> What happens if you increase these sysctls ?

I don't see packet loss after I tweak these two sysctls according to
your suggestions.

Tweaking eth0's sysctls did not change anything, but tweaking gphy's
sysctl resolved the loss. This was a little surprising considering that
gphy is an IFF_NO_QUEUE interface and eth0 is the conduit interface that
does the real transmission.

Does that make sense with respect to what I reported earlier? Should I
try to dump the neigh stats?

Thanks!

> 
> grep .  `find /proc/sys|grep unres_qlen`
> 
> 
> unres_qlen_bytes -> 2000000
> unres_qlen -> 10000
> 
> 


-- 
Florian
