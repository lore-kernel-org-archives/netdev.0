From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udp: fix bcast packet reception
Date: Mon, 09 Oct 2017 10:29:18 -0700 (PDT)
Message-ID: <20171009.102918.193745106051263192.davem@davemloft.net>
References: <66294c8d1c61bdf0bff23a6339a24b4483246caa.1507394363.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52582 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751635AbdJIR3T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 13:29:19 -0400
In-Reply-To: <66294c8d1c61bdf0bff23a6339a24b4483246caa.1507394363.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Mon,  9 Oct 2017 14:52:10 +0200

> The commit bc044e8db796 ("udp: perform source validation for
> mcast early demux") does not take into account that broadcast packets
> lands in the same code path and they need different checks for the
> source address - notably, zero source address are valid for bcast
> and invalid for mcast.
> 
> As a result, 2nd and later broadcast packets with 0 source address
> landing to the same socket are dropped. This breaks dhcp servers.
> 
> Since we don't have stringent performance requirements for ingress
> broadcast traffic, fix it by disabling UDP early demux such traffic.
> 
> Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Fixes: bc044e8db796 ("udp: perform source validation for mcast early demux")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied and queued up for -stable.
