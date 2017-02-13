From: Anoob Soman <anoob.soman@citrix.com>
Subject: Re: [PATCH net] packet: Do not call fanout_release from atomic
 contexts
Date: Mon, 13 Feb 2017 14:50:30 +0000
Message-ID: <64b9aba2-71c7-6e69-630e-aba995306dbf@citrix.com>
References: <1486730384-18749-1-git-send-email-anoob.soman@citrix.com>
 <1486735077.7793.149.camel@edumazet-glaptop3.roam.corp.google.com>
 <822618dc-9e7f-83dd-1920-6a69aaf27dc0@citrix.com>
 <1486995964.8227.34.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([185.25.65.24]:31583 "EHLO
        SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751504AbdBMOuy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 09:50:54 -0500
In-Reply-To: <1486995964.8227.34.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/02/17 14:26, Eric Dumazet wrote:
> On Mon, 2017-02-13 at 13:28 +0000, Anoob Soman wrote:
>
>> Wouldn't it be easier to call synchronize_net(), before calling
>> fanout_release_data() and kfree(f).
>> The behavior, wrt synchronize_net, would be same as before and
>> fanout_release() will cleanup everything without leaving any residue.
> So we would require two synchronize_net() calls instead of one ?
>
> synchronize_net() is very expensive on some hosts, it is a big hammer.
>
>
>

Yes, one before fanout_release_data() (will be called only if 
fanout->sk_ref == 0) and one after fanout_release().

I understand synchronize_net() is expensive, but adding another 
synchronize_net(),  before fanout_release_data(), will be no different 
from what we have in the existing code.

I can also make sure second synchronize_net() doesn't get called again, 
if fanout_release() calls synchronize_net(), by making fanout_release() 
return something to indicate it has done synchronize_net().


Thanks,

Anoob.
