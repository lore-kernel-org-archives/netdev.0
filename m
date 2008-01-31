From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Thu, 31 Jan 2008 09:23:27 -0800
Message-ID: <20080131092327.75b9c369@extreme>
References: <20080131124632.GA25299@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:48055 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753732AbYAaRXc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 12:23:32 -0500
In-Reply-To: <20080131124632.GA25299@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 31 Jan 2008 13:46:32 +0100
Andi Kleen <andi@firstfloor.org> wrote:

> 
> TSO interacts badly with many queueing disciplines because they rely on 
> reordering packets from different streams and the large TSO packets can 
> make this difficult. This patch disables TSO for sockets that send over 
> devices with non standard queueing disciplines. That's anything but noop 
> or pfifo_fast and pfifo right now.
> 
> Longer term other queueing disciplines could be checked if they
> are also ok with TSO. If yes they can set the TCQ_F_GSO_OK flag too.
> 
> It is still enabled for the standard pfifo_fast because that will never
> reorder packets with the same type-of-service. This means 99+% of all users
> will still be able to use TSO just fine.
> 
> The status is only set up at socket creation so a shifted route
> will not reenable TSO on a existing socket. I don't think that's a 
> problem though.
> 
> Signed-off-by: Andi Kleen <ak@suse.de>
> 


Fix the broken qdisc instead.

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
