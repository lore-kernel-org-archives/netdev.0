From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 03/12] i40e: Handle a single mss packet with more
 than 8 frags
Date: Mon, 17 Nov 2014 06:55:50 -0800
Message-ID: <1416236150.5102.8.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416031715-32498-4-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416075695.17262.86.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1C9F1E54@AcuExch.aculab.com>
	 <1416234687.5102.2.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1C9F1E87@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Serey Kong <serey.kong@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	Shannon Nelson <shannon.nelson@intel.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:38916 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753039AbaKQOzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 09:55:46 -0500
Received: by mail-ie0-f170.google.com with SMTP id tr6so3019082ieb.29
        for <netdev@vger.kernel.org>; Mon, 17 Nov 2014 06:55:46 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1C9F1E87@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-11-17 at 14:40 +0000, David Laight wrote:

> Not that one.
> IIRC is was done to reduce the number of fragments through xennet.
> 
> You really want to try to keep some of the old fragments, just adding
> new ones to merge short sections.
> 
> OTOH 8 fragments isn't enough if the MAC supports TSO (dunno if it does).

I40 is a 40Gb NIC, it supports TSO, obviously.

> The skb_linearize() is only likely to fail for TSO anyway.
> Or rather, if it can't allocate a 4k page you are already stuffed.

So far, nobody wrote the code for this.

Page frag are allocated from pages, so if you cannot allocate a 4k page,
this function has no guarantee to succeed no matter how hard you tried.

alloc_skb_with_frags() was already _much_ better than a single
allocation of order-5 page. But if you feel you can do better, why don't
you provide the code ?
