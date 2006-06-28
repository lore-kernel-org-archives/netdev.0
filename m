From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Wed, 28 Jun 2006 12:18:32 +0200
Message-ID: <20060628101832.GW1376@postel.suug.ch>
References: <44A05FE0.7070203@trash.net> <44A0647A.1070209@trash.net> <20060626145446.948105000@postel.suug.ch> <20060626145515.769648000@postel.suug.ch> <44A0138F.8050208@trash.net> <20060626.104654.98552111.davem@davemloft.net> <20060626184424.GT1376@postel.suug.ch> <44A05FE0.7070203@trash.net> <20060627100309.GU1376@postel.suug.ch> <1151413670.6516.57.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:52962 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932764AbWF1KSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2006 06:18:11 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1151413670.6516.57.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-06-27 09:07
> I am reading the thread backwards, so i may miss some of the obvious.
> I also dont remember the exact discussion we had - but the consensus was
> to leave the field setting as is.
> Note the meta-setter (been sitting on it for too long) also set the
> input_dev.

Could you share that piece of code so I don't have to duplicate
that effort?

> BTW, in regards to the VLANs, what is wrong with using the
> netdev->iflink to figure the real device? 


vlan1
          ifb1
vlan2
vlan3
          ifb2
vlan4

dhcp daemon would bind to ifb1 and use pktinfo cmsg to figure
out whether the packet was received on vlan1 or vlan2, the
actual physical device is of no interest anymore.

Looking at your ifb code I see that you set skb->dev based on
iif and update iif unconditionally. I see a lot of problems
with this, firstly iif is already updated in the mirred action,
secondly iif doesn't necessarily point to the device the packet
was last seen on. Could you maybe explain the policy of iif
you have in mind, it doesn't seem very consistent.

BTW, why does ifb have a hard header length? The resulting
push and pull only slows things down.
