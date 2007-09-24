From: David Miller <davem@davemloft.net>
Subject: Re: pktgen question
Date: Mon, 24 Sep 2007 10:40:16 -0700 (PDT)
Message-ID: <20070924.104016.74732763.davem@davemloft.net>
References: <1190571527.4256.78.camel@localhost>
	<46F75968.4010307@candelatech.com>
	<46F7C185.1030202@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, hadi@cyberus.ca, johnpol@2ka.mipt.ru,
	netdev@vger.kernel.org, Robert.Olsson@data.slu.se
To: swise@opengridcomputing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48099
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751117AbXIXRkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2007 13:40:16 -0400
In-Reply-To: <46F7C185.1030202@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steve Wise <swise@opengridcomputing.com>
Date: Mon, 24 Sep 2007 08:54:13 -0500

> I think pktgen should be cloning the skbs using skb_clone().  Then it 
> will work for all devices, eh?

The problem is that skb_clone() is (relatively) expensive and
pktgen is trying to just grab a reference to the SKB in
the absolutely cheapest way possible.

In my personal opinion, I think what the drivers that don't
work with pktgen are doing is wrong and they should find
another way to pass state around other than to depend upon
being able to use the ->cb[] area at-will.
