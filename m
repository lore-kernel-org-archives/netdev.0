From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: Don't override return code from
 ip_route_input_noref()
Date: Sun, 03 Sep 2017 10:55:48 -0700 (PDT)
Message-ID: <20170903.105548.660408350943707381.davem@davemloft.net>
References: <c4d8970306e614ac139cf2f33ab5e6bb73b30154.1504194307.git.sbrivio@redhat.com>
        <20170831234506.GA1838@bistromath.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sbrivio@redhat.com, netdev@vger.kernel.org, weiwan@google.com
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56354 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753061AbdICRzt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 13:55:49 -0400
In-Reply-To: <20170831234506.GA1838@bistromath.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Fri, 1 Sep 2017 01:45:06 +0200

> 2017-08-31, 18:11:41 +0200, Stefano Brivio wrote:
>> After ip_route_input() calls ip_route_input_noref(), another
>> check on skb_dst() is done, but if this fails, we shouldn't
>> override the return code from ip_route_input_noref(), as it
>> could have been more specific (i.e. -EHOSTUNREACH).
>> 
>> This also saves one call to skb_dst_force_safe() and one to
>> skb_dst() in case the ip_route_input_noref() check fails.
>> 
>> Reported-by: Sabrina Dubroca <sdubroca@redhat.com>
>> Fixes: ad65a2f05695 ("ipv4: call dst_hold_safe() properly")
> 
> That should be instead:
> 
> Fixes: 9df16efadd2a ("ipv4: call dst_hold_safe() properly")
> 
> Acked-by: Sabrina Dubroca <sd@queasysnail.net>

Applied with fixed Fixes: tag, thanks.
