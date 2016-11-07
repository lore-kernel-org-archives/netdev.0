From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] qed: Prevent stack corruption on MFW
 interaction
Date: Mon, 7 Nov 2016 12:17:46 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB021652B@AcuExch.aculab.com>
References: <1478445147-23163-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Yuval Mintz' <Yuval.Mintz@cavium.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.185]:53907 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750776AbcKGMVR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 07:21:17 -0500
In-Reply-To: <1478445147-23163-1-git-send-email-Yuval.Mintz@cavium.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz
> Sent: 06 November 2016 15:12
 
> Driver uses a union for copying data to & from management firmware
> when interacting with it.
> Problem is that the function always copies sizeof(union) while commit
> 2edbff8dcb5d ("qed: Learn resources from management firmware") is casting
> a union elements which is of smaller size [24-byte instead of 88-bytes].
> 
> Also, the union contains some inappropriate elements which increase its
> size [should have been 32-bytes]. While this shouldn't corrupt other
> PF messages to the MFW [as management firmware enforces permissions so
> that each PF is allowed to write only to its own mailbox] we fix this
> here as well.
...

Is it worth adding a compile-time assert on the size of the union?

	David
