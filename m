From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: mirred, redirect action vs. dev refcount issue
Date: Wed, 21 Jul 2010 16:52:47 -0700
Message-ID: <20100721165247.6d1dd879@nehalam>
References: <20100721162426.5aa4b646@nehalam>
	<20100721.163955.12041610.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53813 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755340Ab0GUXwu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jul 2010 19:52:50 -0400
In-Reply-To: <20100721.163955.12041610.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 Jul 2010 16:39:55 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 21 Jul 2010 16:24:26 -0700
> 
> > Alternatively, the mirror/redirect could just use ifindex which is
> > a soft reference, so if device is removed, they just drop.
> > 
> > Lazy me favors the later.
> 
> If it is the action rule holding onto the device, it should have
> an appropriate netdevice notifier handler.

There is no notifier there, and the module doesn't keep track of
list of filters. So that is why it has to be done at act api level.

> If it's a transient reference on receive, it should be transient
> and released eventually.

Kernel doesn't keep transient reference on receive any more.
