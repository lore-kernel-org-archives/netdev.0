From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ixgbevf: fix invalid use of napi_hash_del()
Date: Wed, 16 Nov 2016 07:25:16 -0800
Message-ID: <1479309916.8455.195.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1479309315.8455.189.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35545 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752263AbcKPPZS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 10:25:18 -0500
Received: by mail-pg0-f68.google.com with SMTP id p66so14979652pga.2
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 07:25:18 -0800 (PST)
In-Reply-To: <1479309315.8455.189.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-11-16 at 07:15 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Calling napi_hash_del() before netif_napi_del() is dangerous
> if a synchronize_rcu() is not enforced before NAPI struct freeing.
> 
> Lets leave this detail to core networking stack to get it right.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    3 ---
>  1 file changed, 3 deletions(-)

Will send a v2

Same stuff is needed in ixgbevf_free_q_vectors()
