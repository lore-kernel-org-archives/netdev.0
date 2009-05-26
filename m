From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH][be2net] Code changes to handle dev pvt
 ioctl
Date: Tue, 26 May 2009 14:57:30 -0700 (PDT)
Message-ID: <20090526.145730.86993591.davem@davemloft.net>
References: <20090524053149.GA17527@serverengines.com>
	<20090525.003422.117077559.davem@davemloft.net>
	<20090526104852.GA27698@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sarveshwarb@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32974
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755804AbZEZV5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 17:57:31 -0400
In-Reply-To: <20090526104852.GA27698@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Date: Tue, 26 May 2009 16:18:53 +0530

> 
> The private ioctl is being implemented primarily to meet the following OEM
> requirements.
> 
> 1.  A mechanism to retrieve the last post mortem dump of the firmware and h/w
> state.

Belongs in ethtool.

> 2.  Fine tune port equalization parameters of the physical ports.

Belongs in the driver, definitely not in userspace via random pokes
via this new ioctl.  Maybe it would be OK to do this with a new very
well defined ethtool command.

> 3.  A mechanism to flash the firmware at any point (not just at driver load
> time).

Also belongs in ethtool.

All of this is about the typing of the interface.  What you're adding
with the private ioctl is a big black box that no application
developer can code to and have it work on other cards supporting
similar facilities.

We need consistent interfaces that any driver trying to do this can use,
not a different hack in every driver.
