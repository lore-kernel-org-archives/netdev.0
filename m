From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH 4/8] can: Driver for the SJA1000 CAN controller
Date: Fri, 01 May 2009 20:21:15 +0200
Message-ID: <49FB3D9B.3050704@grandegger.com>
References: <1235070082-7069-1-git-send-email-wg@grandegger.com>	<1235070082-7069-2-git-send-email-wg@grandegger.com>	<1235070082-7069-3-git-send-email-wg@grandegger.com>	<1235070082-7069-4-git-send-email-wg@grandegger.com>	<1235070082-7069-5-git-send-email-wg@grandegger.com> <20090219171440.0c8286a1@bike.lwn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Jonathan Corbet <corbet@lwn.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:60732 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754709AbZEASVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 14:21:19 -0400
In-Reply-To: <20090219171440.0c8286a1@bike.lwn.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm now back fixing the open issues of this patch series...

Jonathan Corbet wrote:
[snip]
>> +/*
>> + * SJA1000 private data structure
>> + */
>> +struct sja1000_priv {
>> +	struct can_priv can;	/* must be the first member! */
> 
> AHA!  I knew it!
> 
> This kind of pointer trickery is fragile and dangerous, please don't do
> it.  Much better would be something like:
> 
> 	dev->priv = &dev_specific_priv->can;
> 
> Then the higher layers know they have a proper struct can_priv pointer.
> Then you can use container_of() at this level to get the outer structure
> pointer.  Much more robust and in line with normal kernel coding idiom.

Unfortunately, the "struct net_device" does not have a "priv" field. Using

	struct can_priv *can = netdev_priv(dev);
	struct sja1000_priv *sja1000 = candev_priv(dev);

instead is awkward. That's what we had at first. Any other more elegant
solution in mind?

Wolfgang.

