From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] rtnetlink: delay RTM_DELLINK notification
 until after ndo_uninit()
Date: Tue, 02 Dec 2014 08:19:10 -0800
Message-ID: <1417537150.5303.67.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1417499650-29176-1-git-send-email-maheshb@google.com>
	 <547DE418.9000309@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mahesh Bandewar <maheshb@google.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:36729 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932252AbaLBQTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 11:19:13 -0500
Received: by mail-ig0-f179.google.com with SMTP id r2so11077090igi.12
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 08:19:12 -0800 (PST)
In-Reply-To: <547DE418.9000309@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-12-02 at 08:08 -0800, Roopa Prabhu wrote:

> interestingly I have never seen this. We use this heavily with most 
> other logical devices.
> Which tells me most logical devices do have checks in their fill_info.
> The patch idea is good. My only concern is stale information
> in the DELLINK notification. Because,  ndo_uninit() does do a lot of 
> cleanup, sending
> newlink's for some of these cleanup changes. And now with your patch the 
> dellink notification
> skb probably  contains information that has been already deleted by 
> ndo_uninit ?

What do you mean ? We send a message and device is deleted.

Its an asynchronous message.

At the time you read it, lot of things might already have changed, no
matter how careful you are.

This patch permits to get a precise snapshot of device info right before
dismantle (like stats counters for accounting purpose)
