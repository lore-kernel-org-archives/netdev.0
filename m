From: Manfred Rudigier <manfred.rudigier@omicron.at>
Subject: RE: [PATCH] gianfar: Fix invalid TX frames returned on error queue
 when time stamping.
Date: Mon, 9 Jan 2012 08:16:01 +0100
Message-ID: <95DC1AA8EC908B48939B72CF375AA5E3013A99124D@alice.at.omicron.at>
References: <1325775021-23049-1-git-send-email-manfred.rudigier@omicron.at>
 <20120105.132637.2130515220408371607.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"afleming@freescale.com" <afleming@freescale.com>,
	"avorontsov@mvista.com" <avorontsov@mvista.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:53569 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753493Ab2AIHQ0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2012 02:16:26 -0500
In-Reply-To: <20120105.132637.2130515220408371607.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller [mailto:davem@davemloft.net]
Sent: Thursday, January 05, 2012 19:27

>From: Manfred Rudigier <manfred.rudigier@omicron.at>
>Date: Thu, 5 Jan 2012 15:50:21 +0100
>
>> +
>> +		/* Keep sock if we must return a time stamp on the err queue */
>> +		skb_new->sk = skb->sk;
>
>When I see something like this without any kind of reference counting or
>similar, I am gravely concerned.

The skb_tstamp_tx function called during gfar_clean_tx_ring requires the skb->sk pointer to be set. Otherwise no time stamp can be queued on the socket error queue. 
What would be the correct way for doing this?

Regards,
Manfred
