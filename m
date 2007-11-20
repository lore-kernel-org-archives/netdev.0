From: David Miller <davem@davemloft.net>
Subject: Re: Netfilter: kernel panic with REDIRECT target. (2.6.23 and
 2.6.23.8)
Date: Tue, 20 Nov 2007 04:27:54 -0800 (PST)
Message-ID: <20071120.042754.193323432.davem@davemloft.net>
References: <20071120115520.GB30752@2ka.mipt.ru>
	<4742CEDF.2020102@trash.net>
	<4742D1F1.20805@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, david@unsolicited.net, ismail@pardus.org.tr,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35952
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756870AbXKTM1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 07:27:55 -0500
In-Reply-To: <4742D1F1.20805@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 20 Nov 2007 13:24:17 +0100

> I now understand whats happening:
> 
> - new connection is allocated without helper
> - connection is REDIRECTed to localhost
> - nf_nat_setup_info adds NAT extension, but doesn't initialize it yet
> - nf_conntrack_alter_reply performs a helper lookup based on the
>    new tuple, finds the SIP helper and allocates a helper extension,
>    causing reallocation because of too little space
> - nf_nat_move_storage is called with the uninitialized nat extension
> 
> So your fix is entirely correct, thanks a lot :)

Great, I've applied Evgeniy's patch.
