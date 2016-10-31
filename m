From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3]ldmvsw: tx queue stuck in stopped state
 after LDC reset
Date: Mon, 31 Oct 2016 15:20:49 -0400 (EDT)
Message-ID: <20161031.152049.1501627749475142269.davem@davemloft.net>
References: <b8d6abc7188e5cac885905854067444cb89a5f3b.1477678860.git.Aaron.Young@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sowmini.varadhan@oracle.com
To: Aaron.Young@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56390 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S944276AbcJaTUu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 15:20:50 -0400
In-Reply-To: <b8d6abc7188e5cac885905854067444cb89a5f3b.1477678860.git.Aaron.Young@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Young <Aaron.Young@oracle.com>
Date: Fri, 28 Oct 2016 14:26:19 -0400

> From: Aaron Young <aaron.young@oracle.com>
> 
> The following patch fixes an issue with the ldmvsw driver where
> the network connection of a guest domain becomes non-functional after
> the guest domain has panic'd and rebooted.
> 
> The root cause was determined to be from the following series of
> events:
> 
> 1. Guest domain panics - resulting in the guest no longer processing
>    network packets (from ldmvsw driver)
> 2. The ldmvsw driver (in the control domain) eventually exerts flow
>    control due to no more available tx drings and stops the tx queue
>    for the guest domain
> 3. The LDC of the network connection for the guest is reset when
>    the guest domain reboots after the panic.
> 4. The LDC reset event is received by the ldmvsw driver and the ldmvsw
>    responds by clearing the tx queue for the guest.
> 5. ldmvsw waits indefinitely for a DATA ACK from the guest - which is
>    the normal method to re-enable the tx queue. But the ACK never comes
>    because the tx queue was cleared due to the LDC reset.
> 
> To fix this issue, in addition to clearing the tx queue, re-enable the
> tx queue on a LDC reset. This prevents the ldmvsw from getting caught in
> this deadlocked state of waiting for a DATA ACK which will never come.
> 
> Signed-off-by: Aaron Young <Aaron.Young@oracle.com>
> Acked-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

Applied, thank you.
