From: David Miller <davem@davemloft.net>
Subject: Re: fib_rules: Resolve goto rules target on delete
Date: Tue, 20 Jun 2017 12:40:40 -0400 (EDT)
Message-ID: <20170620.124040.491492963882254347.davem@davemloft.net>
References: <1497617087-26386-1-git-send-email-serhe.popovych@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: serhe.popovych@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37918 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750925AbdFTQkm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 12:40:42 -0400
In-Reply-To: <1497617087-26386-1-git-send-email-serhe.popovych@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Serhey Popovych <serhe.popovych@gmail.com>
Date: Fri, 16 Jun 2017 15:44:47 +0300

> We should avoid marking goto rules unresolved when their
> target is actually reachable after rule deletion.
> 
> Consolder following sample scenario:
> 
>   # ip -4 ru sh
>   0:      from all lookup local
>   32000:  from all goto 32100
>   32100:  from all lookup main
>   32100:  from all lookup default
>   32766:  from all lookup main
>   32767:  from all lookup default
> 
>   # ip -4 ru del pref 32100 table main
>   # ip -4 ru sh
>   0:      from all lookup local
>   32000:  from all goto 32100 [unresolved]
>   32100:  from all lookup default
>   32766:  from all lookup main
>   32767:  from all lookup default
> 
> After removal of first rule with preference 32100 we
> mark all goto rules as unreachable, even when rule with
> same preference as removed one still present.
> 
> Check if next rule with same preference is available
> and make all rules with goto action pointing to it.
> 
> Signed-off-by: Serhey Popovych <serhe.popovych@gmail.com>

Applied, thanks.

It would be awesome if you could distill the above into a test case that
could be run under tools/testing/selftests/networking.

Thanks!
