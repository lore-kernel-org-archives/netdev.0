From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v2 2/2] qede: Add driver support for PTP.
Date: Tue, 31 Jan 2017 10:03:26 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB02749AC@AcuExch.aculab.com>
References: <1485674903-27689-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1485674903-27689-3-git-send-email-Sudarsana.Kalluru@cavium.com>
 <20170129153536.GD2223@localhost.localdomain>,<063D6719AE5E284EB5DD2968C1650D6DB0273BA8@AcuExch.aculab.com>
 <BL2PR07MB2306B5963EBDEF0AF5CD4E8F8D4B0@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "'Mintz, Yuval'" <Yuval.Mintz@cavium.com>,
        'Richard Cochran' <richardcochran@gmail.com>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.190]:55099 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751303AbdAaKkp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 05:40:45 -0500
In-Reply-To: <BL2PR07MB2306B5963EBDEF0AF5CD4E8F8D4B0@BL2PR07MB2306.namprd07.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mintz, Yuval
> Sent: 30 January 2017 17:56
> > How many different implementations of 'ops->adjfreq' are there?
> > If there is only one you don't need an indirect call.
> 
> There's only one implementation. But qed publishes its functions to
> qede [and other modules] by structs of operations and not by
> exporting symbols directly, and I don't see a reason to change that
> paradigm here.
> [Although I might be mistaken about that last bit]

If any of the functions are on 'hot paths' the cost of the indirect
call is likely to be measurable.
On a lot of cpus it will be a pipeline stall.
The double-indirect almost certainly generates a stall.

	David
