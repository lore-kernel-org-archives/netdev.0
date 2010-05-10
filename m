From: David Miller <davem@davemloft.net>
Subject: Re: error in arp.c for Token Ring (IEEE802_TR) and ...
Date: Sun, 09 May 2010 18:45:08 -0700 (PDT)
Message-ID: <20100509.184508.257497526.davem@davemloft.net>
References: <4BE739B1.8040509@rgc1.inka.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rgc@rgc1.inka.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49470
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754160Ab0EJBpC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 May 2010 21:45:02 -0400
In-Reply-To: <4BE739B1.8040509@rgc1.inka.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claus Regelmann <rgc@rgc1.inka.de>
Date: Mon, 10 May 2010 00:39:45 +0200

> 
> So the question is why CONFIG_TR is undefined allthought .config says:
> ...
> # CONFIG_NETDEV_1000 is not set
> # CONFIG_NETDEV_10000 is not set
> CONFIG_TR=m

Because when a configuration setting is set to "m" that makes
CONFIG_FOO_MODULE get defined instead of plain CONFIG_FOO.

So these places that test CONFIG_TR need to be changed to instead
test "defined(CONFIG_TR) || defined(CONFIG_TR_MODULE)"
