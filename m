From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/2] Use correct sk->sk_prot for IPV6
Date: Tue, 05 Sep 2017 14:38:42 -0700 (PDT)
Message-ID: <20170905.143842.193794174652230489.davem@davemloft.net>
References: <1504520041-55634-1-git-send-email-ilyal@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davejwatson@fb.com, aviadye@mellanox.com
To: ilyal@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39630 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752222AbdIEVin (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 17:38:43 -0400
In-Reply-To: <1504520041-55634-1-git-send-email-ilyal@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilya Lesokhin <ilyal@mellanox.com>
Date: Mon,  4 Sep 2017 13:13:59 +0300

> The tls ulp overrides sk->prot with a new tls specific proto structs.            
> The tls specific structs were previously based on the ipv4 specific              
> tcp_prot sturct.                                                                 
> As a result, attaching the tls ulp to an ipv6 tcp socket replaced                
> some ipv6 callback with the ipv4 equivalents.                                    
>                                                                                  
> This patch adds ipv6 tls proto structs and uses them when                        
> attached to ipv6 sockets. 
> 
> Changed since v2: 
> - Dropped patch to fix IPV6_ADDRFORM setsockopt
> There was some disagreement about the correct way of fixinig it,
> and this series does not depend on it.
> 
> Changes since v1:                                                                
> - TLS now dependes on IPV6                                                       
> This fixes complication issues when TLS is built-in and IPV6 is a module.        
> The downside should be small as it is unlikely that there are kernel TLS         
> users who can't afford to include IPV6 in thier kernel.                          

This is not acceptable.

Forcing such a huge piece of infrastructure like ipv6 to be statically
built just because someone wants to enable TLS is not going to pass.

Every distrubtion out there will enable all features, including TLS,
so effectively you are forcing every distribution to build ipv6
non-modules.

Sorry, you will have to fix this in a way that allows TLS and IPV6
to be modular.
