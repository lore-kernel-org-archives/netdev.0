From: David Miller <davem@davemloft.net>
Subject: Re: [iproute2] iproute2: Allow 'ip addr flush' to loop more than
 10 times.
Date: Mon, 28 Jun 2010 23:12:04 -0700 (PDT)
Message-ID: <20100628.231204.229752207.davem@davemloft.net>
References: <1277790959-28075-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, greearb@candelatech.com
To: greearb@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49819
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751336Ab0F2GLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 02:11:51 -0400
In-Reply-To: <1277790959-28075-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: greearb@gmail.com
Date: Mon, 28 Jun 2010 22:55:59 -0700

> From: Ben Greear <greearb@candelatech.com>
> 
> The default remains at 10 for backwards compatibility.
> 
> For instance:
>  # ip addr flush dev eth2
>  *** Flush remains incomplete after 10 rounds. ***
>  # ip -l 20 addr flush dev eth2
>  *** Flush remains incomplete after 20 rounds. ***
>  # ip -loops 0 addr flush dev eth2
>  #
> 
> This is useful for getting rid of large numbers of IP
> addresses in scripts.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>

I would suggest to instead add some logic to this code to detect that
forward progress is being made.

I really don't see any value in having a hard limit that triggers on a
bulk delete when no other address changing activity is happening in
the system.
