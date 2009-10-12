From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 2/3] sky2: Reading registers in reset causes a hang
Date: Mon, 12 Oct 2009 09:14:59 -0700
Message-ID: <20091012091459.49eb1188@nehalam>
References: <4AD337ED.4090409@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:47549 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932733AbZJLQQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 12:16:35 -0400
In-Reply-To: <4AD337ED.4090409@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 Oct 2009 23:06:37 +0900
Mike McCormack <mikem@ring3k.org> wrote:

> When sky2 hardware is in reset, reading registers with ethtool -d
> causes a hard system hang. eg.
> 
>     ifconfig eth1 down
>     ethtool -d eth1
> 
> Avoid reading FIFOs, descriptor and status unit, etc. after we've
>  bought the interface down, as these seem to cause the issue.
> 
> Assume the same is true for the second port, as my port only has
>  one card.

I don't see this on my cards. Let me investigate further before
committing this. Also, the debugfs interface would also be screwed
if the registers were unavailable.
