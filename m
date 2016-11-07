From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v6 02/10] dpaa_eth: add support for DPAA
 Ethernet
Date: Mon, 07 Nov 2016 11:39:41 -0500 (EST)
Message-ID: <20161107.113941.669208733868640796.davem@davemloft.net>
References: <AM4PR04MB16049FF6E433DA445828A855ECA70@AM4PR04MB1604.eurprd04.prod.outlook.com>
        <20161107.105500.43380129278294700.davem@davemloft.net>
        <AM4PR04MB1604B2393D5CE6607204800EECA70@AM4PR04MB1604.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-kernel@vger.kernel.org, oss@buserror.net,
        ppc@mindchasers.com, joe@perches.com, pebolle@tiscali.nl,
        joakim.tjernlund@transmode.se
To: madalin.bucur@nxp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36282 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753234AbcKGQjo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 11:39:44 -0500
In-Reply-To: <AM4PR04MB1604B2393D5CE6607204800EECA70@AM4PR04MB1604.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Madalin-Cristian Bucur <madalin.bucur@nxp.com>
Date: Mon, 7 Nov 2016 16:32:16 +0000

>> -----Original Message-----
>> From: David Miller [mailto:davem@davemloft.net]
>> Sent: Monday, November 07, 2016 5:55 PM
>> 
>> From: Madalin-Cristian Bucur <madalin.bucur@nxp.com>
>> Date: Mon, 7 Nov 2016 15:43:26 +0000
>> 
>> >> From: David Miller [mailto:davem@davemloft.net]
>> >> Sent: Thursday, November 03, 2016 9:58 PM
>> >>
>> >> Why?  By clearing this, you disallow an important fundamental way to do
>> >> performane testing, via pktgen.
>> >
>> > The Tx path in DPAA requires one to insert a back-pointer to the skb
>> into
>> > the Tx buffer. On the Tx confirmation path the back-pointer in the
>> buffer
>> > is used to release the skb. If Tx buffer is shared we'd alter the back-
>> pointer
>> > and leak/double free skbs. See also
>> 
>> Then have your software state store an array of SKB pointers, one for each
>> TX ring entry, just like every other driver does.
> 
> There is no Tx ring in DPAA. Frames are send out on QMan HW queues towards
> the FMan for Tx and then received back on Tx confirmation queues for cleanup.
> Array traversal would for sure cost more than using the back-pointer. Also,
> we can now process confirmations on a different core than the one doing Tx,
> we'd have to keep the arrays percpu and force the Tx conf on the same core.
> Or add locks.

Report back an integer index, like every scsi driver out there which
completes tagged queued block I/O operations asynchronously.  You can
associate the array with a specific TX confirmation queue.
