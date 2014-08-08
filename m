From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] xen-netback: Changes around carrier
 handling
Date: Thu, 07 Aug 2014 22:29:05 -0700 (PDT)
Message-ID: <20140807.222905.354652678816300998.davem@davemloft.net>
References: <1407165658-20146-1-git-send-email-zoltan.kiss@citrix.com>
	<20140805.160748.1185917042908283028.davem@davemloft.net>
	<53E3AE21.50109@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, Ian.Campbell@citrix.com,
	david.vrabel@citrix.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
To: zoltan.kiss@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55651 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755799AbaHHF3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2014 01:29:06 -0400
In-Reply-To: <53E3AE21.50109@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Thu, 7 Aug 2014 17:49:37 +0100

> David Vrabel pointed out an important question in a reply to the
> previous version of this series: this patch deschedule NAPI if the
> carrier goes down. The backend doesn't receive packets from the
> guest. DavidVr and others said we shouldn't do this, the guest should
> be able to transmit even if it's not able/willing to receive. Other
> drivers doesn't deschedule NAPI at carrier off as well, however the
> "carrier off" information comes from the hardware, not from an
> untrusted guest who is not posting buffers on the receive ring.
> I don't have any good argument why I did it the current way, other
> than a hunch that it feels more natural.
> David, do you have an opinion on that?

Unless you have a strong reason for doing so, I don't think disabling
receives when the TX path backs up is necessary.
