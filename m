From: David Miller <davem@davemloft.net>
Subject: Re: mirred, redirect action vs. dev refcount issue
Date: Wed, 21 Jul 2010 16:39:55 -0700 (PDT)
Message-ID: <20100721.163955.12041610.davem@davemloft.net>
References: <20100721162426.5aa4b646@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48795
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755340Ab0GUXjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 19:39:39 -0400
In-Reply-To: <20100721162426.5aa4b646@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 21 Jul 2010 16:24:26 -0700

> Alternatively, the mirror/redirect could just use ifindex which is
> a soft reference, so if device is removed, they just drop.
> 
> Lazy me favors the later.

If it is the action rule holding onto the device, it should have
an appropriate netdevice notifier handler.

If it's a transient reference on receive, it should be transient
and released eventually.
