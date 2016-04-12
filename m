From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ibmvnic: Defer tx completion processing using
 a wait queue
Date: Tue, 12 Apr 2016 13:12:20 -0700
Message-ID: <1460491940.6473.592.camel@edumazet-glaptop3.roam.corp.google.com>
References: <570D4EBC.60409@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: John Allen <jallen@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:36538 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756983AbcDLUMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 16:12:23 -0400
Received: by mail-pf0-f171.google.com with SMTP id e128so19674145pfe.3
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 13:12:22 -0700 (PDT)
In-Reply-To: <570D4EBC.60409@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-04-12 at 14:38 -0500, John Allen wrote:
> Moves tx completion processing out of interrupt context, deferring work
> using a wait queue. With this work now deferred, we must account for the
> possibility that skbs can be sent faster than we can process completion
> requests in which case the tx buffer will overflow. If the tx buffer is
> full, ibmvnic_xmit will return NETDEV_TX_BUSY and stop the current tx
> queue. Subsequently, the queue will be restarted in ibmvnic_complete_tx
> when all pending tx completion requests have been cleared.

1) Why is this needed ?

2) If it is needed, why is this not done in a generic way, so that other
drivers can use this ?

Thanks.
