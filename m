From: Werner Almesberger <werner@almesberger.net>
Subject: Re: [Linux-zigbee-devel] [PATCH] mac802154: Keep track of the
 channel when changed
Date: Fri, 5 Apr 2013 18:05:14 -0300
Message-ID: <20130405210514.GF28141@ws>
References: <1365194201-2635-1-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net
To: Alan Ott <alan@signal11.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.openmoko.org ([88.198.124.205]:50603 "EHLO
	mail.openmoko.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162241Ab3DEVGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 17:06:25 -0400
Content-Disposition: inline
In-Reply-To: <1365194201-2635-1-git-send-email-alan@signal11.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alan Ott wrote:
> Prevent set_channel() from getting called every time a packet is sent. This
> looks like it was an oversight.

at86rf230.c and derivatives avoid this problem by setting
phy->current_* in the *_channel function.

But I'd agree that it's nicer to do this in one place, not in
every driver.

In case a driver had a weird failure mode in which it leaves the
original channel but only makes it halfway to the new channel, it
could still set phy->current_* and return an error. So there's no
loss of functionality with your change.

- Werner
