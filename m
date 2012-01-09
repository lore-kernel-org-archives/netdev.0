From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] gianfar: Fix invalid TX frames returned on error queue
 when time stamping.
Date: Mon, 9 Jan 2012 13:49:08 +0100
Message-ID: <20120109124908.GB4404@cherladcori01>
References: <1325775021-23049-1-git-send-email-manfred.rudigier@omicron.at>
 <20120105.132637.2130515220408371607.davem@davemloft.net>
 <95DC1AA8EC908B48939B72CF375AA5E3013A99124D@alice.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"afleming@freescale.com" <afleming@freescale.com>,
	"avorontsov@mvista.com" <avorontsov@mvista.com>
To: Manfred Rudigier <manfred.rudigier@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:39535 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753550Ab2AIMtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2012 07:49:14 -0500
Received: by wgbdt14 with SMTP id dt14so1449884wgb.1
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2012 04:49:13 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <95DC1AA8EC908B48939B72CF375AA5E3013A99124D@alice.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 09, 2012 at 08:16:01AM +0100, Manfred Rudigier wrote:
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, January 05, 2012 19:27
> 
> >From: Manfred Rudigier <manfred.rudigier@omicron.at>
> >Date: Thu, 5 Jan 2012 15:50:21 +0100
> >
> >> +
> >> +		/* Keep sock if we must return a time stamp on the err queue */
> >> +		skb_new->sk = skb->sk;
> >
> >When I see something like this without any kind of reference counting or
> >similar, I am gravely concerned.
> 
> The skb_tstamp_tx function called during gfar_clean_tx_ring requires
> the skb->sk pointer to be set. Otherwise no time stamp can be queued
> on the socket error queue.
> What would be the correct way for doing this?

Hi Manfred,

You have to make sure the new clone holds a reference on skb->sk.
A recent, similar problem was discussed:

    http://comments.gmane.org/gmane.linux.network/208143

And the solution came in:

    commit da92b194cc36b5dc1fbd85206aeeffd80bee0c39
    Author: Richard Cochran <richardcochran@gmail.com>
    Date:   Fri Oct 21 00:49:15 2011 +0000

    net: hold sock reference while processing tx timestamps

HTH,

Richard
