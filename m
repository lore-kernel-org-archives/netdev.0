From: David Miller <davem@davemloft.net>
Subject: Re: [WIP][PATCHES] Network xmit batching - tg3 support
Date: Tue, 03 Jul 2007 14:30:17 -0700 (PDT)
Message-ID: <20070703.143017.122063558.davem@davemloft.net>
References: <1182989145.5155.81.camel@localhost>
	<1183411245.6609.16.camel@teletran1>
	<1183468188.5159.73.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, Robert.Olsson@data.slu.se,
	johnpol@2ka.mipt.ru, krkumar2@in.ibm.com, gaagaan@gmail.com,
	netdev@vger.kernel.org, rick.jones2@hp.com, sri@us.ibm.com,
	jeff@garzik.org, mchan@broadcom.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35914
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754018AbXGCV35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 17:29:57 -0400
In-Reply-To: <1183468188.5159.73.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Tue, 03 Jul 2007 09:09:48 -0400

> [It sounds very dangerous to me the way skb->cb is being used by the
> vlan code (i.e requires human intervention/knowledge to catch it as an
> issue). I had no freaking idea the vlan code was using it. Maybe a huge
> comment somewhere on how these cbs are being used by drivers would help
> or even a registration on startup to just make sure there is no conflict
> at a layer (i have been meaning to do the later for years now). In any
> case this is is a digression]. 

This is how the VLAN layer passed in the tag for the transmit
function.

The CB is owned by the caller until you spam it with your local
data at your level, so if you need any information the previous
layer provides you have to sample it before using the ->cb[]

So you can simply fix this by reading the VLAN tag, then using
the ->cb[] however you like.

It's always been like this, don't be surprised :)
